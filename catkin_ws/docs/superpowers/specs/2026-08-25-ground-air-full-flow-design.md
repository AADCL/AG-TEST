# 空地两用无人机全流程设计

## 目标

以 `HZBZ0819` 的四个 ROS1 Noetic 包为行为基线，把真机上分散在多个工作空间中的传感器、定位、导航、平台通信和视频功能收拢到 `/home/bitcq/catkin_ws`，实现以下闭环：

1. 手控建图并向指控平台发送地图和实时点云。
2. 再次进入已有地图时加载地图，并从未知初始位姿完成全局重定位。
3. 接收一组有序任务点，自主导航避障，每个任务点停留 2 秒。
4. 任务执行期间接收起飞、降落和模态切换命令；飞行高度固定为 1.0 米。
5. 飞行模式到达任务点后保持悬停，只有收到地面站降落命令才降落。
6. 持续向指控平台返回实时视频和机器人状态。
7. 急停进入锁存状态，停止任务并阻止后续运动命令，必须显式复位。

## 现有代码审查结论

### 直接复用并做可移植性修正

- `livox_ros_driver2`：真机 MID360 驱动，当前运行链路已经使用。
- `fast_lio_open3d`：真机里程计和手控建图基础；需要去除绝对路径并统一 frame/topic 参数。
- `vision_to_mavros`：把 LIO 位姿送入 MAVROS；保留实际使用的 MID360 启动入口。
- `lidar_ground_filter`、`dynamic_mapping`：保留点云过滤和二维占据栅格生成。
- `teb_local_planner_tutorials` 中的 TEB 配置：保留规划参数，但生产控制代码迁出教程包。
- `spiritwing_web`：保留 WebSocket、状态、地图上传和视频推流脚本；任务、模态及急停逻辑改为调用统一 ROS 接口。

### 仅作算法参考，不原样复用

- 回收站 `open3d_loc`：只在给定初始位姿附近做 ICP，不能满足未知初始位姿；其 FPFH/RANSAC 工具可复用。
- `position_ctrl`、`waypoints_csv`：与 `move_base + TEB` 重复，且依赖旧消息和旧路径，不进入主链路。
- `quadrotor_msgs`：只有旧控制栈需要，主链路不用。
- `LiDAR_IMU_Init`、`pointcloud_to_laserscan_z`、`photo_function`、`data_record`：不属于当前最小闭环，暂不进入默认启动。

### 必须重写或重构

- 当前 `PX4Drone.switch_mode()` 在服务对象非空时可能误判成功，PX4 1.14 分支未实现。
- 当前 `drone_mode_node` 启动即切物理模态，不符合受控切换要求。
- 地面与飞行节点同时订阅 `/cmd_vel`，必须改为单一速度路由器。
- 平台任务序列只按距离推进，暂停后从第 0 点重启，没有 2 秒停留。
- 平台急停只发送瞬时零速度，不是锁存急停。
- 平台重定位发布 `/initialpose` 后立即报告成功，没有定位质量验证。

## 包与职责

### `ground_air_msgs`

定义稳定的 ROS 接口：模态、任务、地图与重定位服务，以及状态消息。所有上层模块只依赖这些接口，不直接调用 PX4 私有实现。

### `ground_air_control`

包含：

- `ModeManagerCore`：`GROUND`、`TAKEOFF`、`AIR`、`LANDING`、`ESTOP`、`FAULT` 状态机。
- `cmd_vel_router`：接收导航速度，按模态唯一转发到地面执行器或飞行控制器。
- `px4_backend`：确认真实 PX4 版本、MAVROS 服务应答和 `extended_state` 后才确认切换成功。
- 起飞目标高度固定为相对起飞点 `1.0 m`。
- 飞行命令超时后保持当前水平位置和目标高度。
- 急停锁存；空中默认进入定点悬停，地面输出持续为零；复位需要 ROS 服务。

### `ground_air_mission`

通过 `actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction>` 执行有序目标点：

- 仅在定位有效且不处于急停时接受任务。
- 使用 action 终态判定成功/失败，不用位置距离代替 action 结果。
- 每个目标成功后停留 2 秒。
- 暂停保存当前索引；恢复从当前索引继续。
- 飞行模式任务点完成后保持悬停；降落只能由显式服务/平台命令触发。

### `ground_air_localization`

- `map_manager` 下载或加载 PCD 与 `map.yaml/map.pgm`，校验文件后原子切换当前地图。
- `global_relocalizer` 使用 Open3D 0.14.1：下采样、法向/FPFH、RANSAC 全局粗配准、multi-scale ICP 精配准。
- 连续两次达到 fitness/RMSE 阈值后发布 `map -> odom`，并将状态置为 `LOCALIZED`。
- `/initialpose` 仅作为可选加速先验，不是未知位姿重定位的必要条件。
- 定位失败或超时保持导航禁止状态，不伪报成功。

### `spiritwing_web`

只负责协议适配：

- 平台任务转给 `ground_air_mission`。
- 起飞、降落、急停、复位转给 `ground_air_control` ROS 服务。
- 地图选择与重定位转给 `ground_air_localization`。
- 状态反馈来自统一状态 topic。
- 保留地图/点云上传以及 RTSP 推流脚本。

### `ground_air_bringup`

提供分阶段 launch：

- `sensors.launch`：MAVROS、MID360、FAST-LIO、vision_to_mavros。
- `mapping.launch`：手控建图、动态二维地图、平台上传。
- `mission.launch`：历史地图、重定位、导航、控制、平台通信、视频。
- `full.launch`：按参数选择 mapping 或 mission，不同时启动互斥地图发布者。

## 安全约束

- 未确认 FCU 连接、位姿新鲜、模态反馈和未急停时，不允许解锁起飞。
- 模态切换必须以真实 `/mavros/extended_state` 为准，禁止修改本地缓存伪造成功。
- 同一时间只有一个节点可以向地面执行器或飞行 setpoint topic 发运动命令。
- 飞行任务到点不自动降落。
- 实机测试分为：编译/单元测试、ROS 图检查、上锁状态控制检查、系留起飞、低速导航。

## 依赖

- Ubuntu 20.04、ROS Noetic、Python 3.8、MAVROS。
- Open3D 官方版本为 `0.14.1`；源码中的 `open3d141` 即此版本。
- Jetson aarch64 按官方 ARM 指南从源码构建，关闭 GUI、CUDA、Python、ML 和示例，仅安装共享 C++ 库。

## 验收边界

代码完成必须同时满足：

- 所有纯逻辑单元测试通过。
- 远程 `catkin_make` 成功。
- `roslaunch --nodes`/`roslaunch-check` 无缺包和重复关键发布者。
- 在不上锁条件下，服务状态机和速度路由可验证。
- 实际起飞、降落和导航最终仍需现场安全条件下由用户配合验证。
