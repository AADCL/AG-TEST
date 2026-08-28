# SpiritWing 路空无人机接入开发状态

更新时间：2026-05-26

## 当前结论

用户已确认本次按 `bingzhi-wurenji/ROS2无人机接入指控系统信息清单-路空.xlsx` 开发，不混用“涵道”无人机资料。

路空资料显示该机为 ROS1 Noetic + Ubuntu 20.04 arm64 + PX4 + MAVROS。
已知核心接口包括：

- `/spiritwing/command`：资料称手控和降落通过 `swing_msgs::UAVCommand`。
- `/spiritwing/patrol_points`：`nav_msgs/Path`，用于多目标巡检/导航。
- `/spiritwing/patrol_state`：`swing_msgs::PatrolState`，用于导航反馈。
- `/mavros/state`：飞控连接、解锁、飞行模式。
- `/mavros/battery`：电池状态。
- `/Odometry`：当前位置、姿态和定位输出。
- `/livox/lidar`：Mid360 原始点云。

路空资料还明确给出：

- 手动控制坐标系：`base_link`。
- 手动控制发布频率：`30-50Hz`。
- 任务点 frame：`world`。
- 起飞语义：`CONTROL_STATE::COMMAND_CONTROL` + `Init_Pos_Hover`。
- 降落语义：`swing_msgs::UAVCommand::Land`。
- 悬停语义：`Current_Pos_Hover`。
- 建图算法：`fast_lio2`。
- 原生生成 `map.pgm/map.yaml`：是。
- 原生生成 PCD：否。

目前没有 `swing_msgs` 消息定义，所以本地先实现一个不依赖 `swing_msgs` 的
可编译框架包 `spiritwing_web`。

## 2026-05-26 真机采集结论

采集目录：

```text
spiritwing_info_19700101_081820
```

本次真机环境与原 Excel 描述存在明显差异：

- `swing_msgs` 包不存在，`swing_msgs/UAVCommand`、`swing_msgs/PatrolState`、`swing_msgs/State` 都无法加载。
- `/spiritwing/command`、`/spiritwing/patrol_points`、`/spiritwing/patrol_state` 不是当前现场主链路。
- 真实导航入口是 `/move_base_simple/goal`，类型 `geometry_msgs/PoseStamped`，订阅者为 `/move_base`。
- `/move_base` 发布 `/cmd_vel`，现场脚本 `cmd_mavros.py` 订阅 `/cmd_vel` 并发布 `/mavros/actuator_control`。
- `/mavros/actuator_control` 类型为 `mavros_msgs/ActuatorControl`，订阅者为 `/mavros`。
- `/Odometry`、`/spiritwing/odom`、`/spiritwing/oodm` 不存在。
- 可用里程计为 `/Odometry` 和 `/mavros/local_position/odom`，其中 `/mavros/local_position/odom` 已采到 `nav_msgs/Odometry` 样例。
- `/livox/lidar` 是 `livox_ros_driver2/CustomMsg`，不能直接给当前 `sensor_msgs/PointCloud2` 点云上传逻辑使用。
- 可用 PointCloud2 topic 包括 `/Laser_map`、`/cloud_registered`、`/cloud_registered_body`。
- `/map` 存在，类型 `nav_msgs/OccupancyGrid`，由 `/dynamic_mapping` 发布，`/move_base` 订阅。
- 现场主要工作空间是 `$HOME/HZBZ` 和 `$HOME/ifc_plus`，不是此前资料里的 `$HOME/spritwing_v1.0`。

已据此调整默认配置：

```yaml
spiritwing_node:
  navigation_backend: "move_base_simple"
  topics:
    odom: "/Odometry"
    fallback_odom: "/mavros/local_position/odom"
    pointcloud: "/cloud_registered"
```

## 已创建代码

```text
bingzhi-wurenji/spiritwing_web
```

主要文件：

- `src/spiritwing_web_node.cpp`：WebSocket + ROS1 桥接主节点。
- `config/params.yaml`：平台地址、SN、topic、控制后端和脚本配置。
- `launch/spiritwing_web.launch`：启动入口。
- `scripts/collect_spiritwing_info.sh`：真机只读信息采集脚本，用于查询 `swing_msgs`、topic、MAVROS、点云、地图文件等现场信息。
- `README.md`：部署和后续补齐说明。
- `CMakeLists.txt` / `package.xml`：ROS1 catkin 包配置。

## 已实现能力

- 指控平台 WebSocket 连接与自动重连。
- `robot_status` 1Hz 状态上报。
- 动态使用平台下发的 `area_id`。
- `multi_goal_down` 解析并缓存多目标点。
- `navigation_start_down` 默认发布首个目标点到 `/move_base_simple/goal`。
- 已根据现场信息新增可配置导航后端：
  - `patrol_points`：发布 `/spiritwing/patrol_points`。
  - `move_base_simple`：发布首个目标点到 `/move_base_simple/goal`。
  - `both`：两者同时发布，便于现场确认真实链路。
- `navigation_pause_down` / `navigation_resume_down` / `navigation_stop_down` 基础处理。
- `relocalize_pose_down` 转 `/initialpose`。
- `manual_control_down` 状态保持、超时清零。
- 已根据现场脚本新增 `cmd_vel` 手控后端：Web 模块发布 `/cmd_vel`，`scripts/cmd_vel_to_actuator_control.py` 转 `/mavros/actuator_control`。
- `slam_start_down` / `slam_stop_down` 基础响应和地图上传占位。
- `takeoff_down` / `land_down` / `emergency_stop_down` 设备扩展协议占位。

## 控制后端设计

当前默认：

```yaml
command_backend: "json_placeholder"
```

原因是没有 `swing_msgs/UAVCommand` 定义，不能可靠构造真正的
`/spiritwing/command` 消息。默认后端会把控制意图封装为 JSON 字符串发布到：

```text
/spiritwing/command_json_placeholder
```

拿到真机或消息定义后，应替换为真正的 `swing_msgs::UAVCommand` 发布逻辑。

可选后端：

```yaml
command_backend: "mavros"
```

该后端使用 MAVROS 标准 service/topic 做兜底控制，仅在现场确认允许时启用。

现场新增可选后端：

```yaml
command_backend: "cmd_vel"
```

该后端发布 `/cmd_vel`，配合无人机现场给出的 `/cmd_vel -> /mavros/actuator_control` 转换脚本使用。当前已把脚本整理为：

```text
scripts/cmd_vel_to_actuator_control.py
```

导航现场新增可选后端：

```yaml
navigation_backend: "move_base_simple"
```

该后端把平台任务点中的第一个点发布为 `geometry_msgs/PoseStamped` 到 `/move_base_simple/goal`。

## 后续必须确认

真机或厂家支持可用后，优先补齐自定义消息定义：

```bash
rosmsg show swing_msgs/UAVCommand
rosmsg show swing_msgs/PatrolState
```

并继续确认：

- `COMMAND_CONTROL`、`Init_Pos_Hover`、`Current_Pos_Hover`、`Land` 的具体字段和值。
- 手控速度字段如何填写。
- 地面/空中/起飞成功/降落完成如何从 ROS topic 判断。
- `/spiritwing/patrol_state` 到点、完成、失败字段。
- `map.pgm/map.yaml` 的真实输出目录。
- `/spiritwing/oodm` 是否为正确拼写，还是应为 `/spiritwing/odom`。

面向厂家沟通的完整问题清单已整理到：

```text
VENDOR_QUESTIONS.md
```

## 真机信息采集脚本

已新增只读采集脚本：

```text
scripts/collect_spiritwing_info.sh
```

在真机上运行：

```bash
cd ~/spiritwing_web_ws
source devel/setup.bash
bash "$(rospack find spiritwing_web)/scripts/collect_spiritwing_info.sh"
```

或指定输出目录：

```bash
bash "$(rospack find spiritwing_web)/scripts/collect_spiritwing_info.sh" /tmp/spiritwing_info
```

脚本不会发布控制指令，不会解锁、起飞、降落或切换模式。它会查询并保存：

- `swing_msgs/UAVCommand`、`swing_msgs/PatrolState`、`swing_msgs/UIState`、`swing_msgs/SensorState` 消息定义。
- `/spiritwing/command`、`/spiritwing/patrol_points`、`/spiritwing/patrol_state` 的类型、info、样例和频率。
- `/spiritwing/state`、`/spiritwing/control_state`、`/spiritwing/sensor_state`、`/spiritwing/ui_state`、`/spiritwing/setup` 等路空资料中列出的状态 topic。
- `/Odometry`、`/spiritwing/oodm`、`/spiritwing/odom`、`/mavros/local_position/odom`，用于确认真实定位 topic 和文档拼写。
- `/livox/lidar`、`/livox/cloud_in_world`、`/Laser_map`、`/Laser_map_filter`、`/cloud_registered` 等点云/地图 topic 的类型和频率，用于后续实时点云和地图上传。
- MAVROS 状态、电池、本地位姿/速度、GPS、RC、IMU、service、参数、TF。
- 全部 ROS topic/service 类型表，用于发现资料未写的真实接口。
- `step0_sensor.sh`、`step1_getMap.sh`、`step2_mission.sh` 等启动脚本路径和内容。
- `$HOME` 和 `/tmp` 下可能的 `map.pgm`、`map.yaml`、`.pcd`、`pose.txt` 文件路径，以及地图相关 service。

2026-05-25 重新阅读原始 Excel 后，脚本已补充采集路空表格中明确出现的关键接口：

- 真实状态：`/spiritwing/state` 样例中包含 `uav_id`、`connected`、`armed`、`mode`、`location_source`、`odom_valid`、`gps_status`、`gps_num`、位置、速度、姿态、电池等字段，是后续 `robot_status` 和飞行状态判断的重点。
- 专有 topic：`/spiritwing/control_state`、`/spiritwing/sensor_state`、`/spiritwing/ui_state`、`/spiritwing/patrol_goal`、`/spiritwing/trajectory`、`/spiritwing/want_local_plan`。
- 建图/地图相关：`/Laser_map`、`/Laser_map_filter`、`/livox/cloud_in_world`、`/fast_lio_sam/mapping/map_global_optimized`、`/occu_raw_map`、`/occu_inflate_map`、`/pub_map`、`/save_map`、`/save_pose`、`/send_map_srv`。
- 规划/导航相关：`/swing_planner_node/goal_point`、`/swing_planner_node/grid_map/occupancy`、`/planning/trajectory`、`/mavros/mission/reached`。

运行完成后，把输出目录整体发回即可继续分析。

## 本地验证限制

当前开发机是 Windows，未安装 ROS/catkin。已尝试执行 `catkin_make`，系统提示
`catkin_make` 不存在。因此本轮只能做静态开发，真实编译需要在 Ubuntu 20.04
ROS Noetic 环境中执行。
