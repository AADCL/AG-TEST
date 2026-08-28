# 空地两用机器人地面模态话题、启动文件、TF树与常见问题表

版本：V1.2
日期：2026-08-28
ROS：ROS1 Noetic
工作空间：`/home/bitcq/catkin_ws`

> 本表集中记录当前地面模态运行接口和诊断基准。实际在线接口最终以 `rosnode list`、`rostopic list`、`rosservice list` 和 `roslaunch --nodes` 为准。

## 1. 状态标记

| 标记 | 含义 |
|---|---|
| **已实机验证** | 当前机器人已跑通 |
| **代码已具备、尚未实机验证** | 接口存在，但未完成完整实机验收 |
| **实机测试未通过** | 已有失败或安全事件，修复并复验前禁止作为可用功能 |
| **当前禁用或不属于地面模态** | 不应按地面模态可用功能操作 |

## 2. 工作模式和禁止同时启动项

| 模式 | 正式入口 | 主要输出 | 禁止同时启动 |
|---|---|---|---|
| 手控建图 | `car_bringup/start_mapping.launch map_id:=<id>` | 建图基础栈、自动开始记录 | 第二套 Livox、FAST-LIO、定位、导航、控制、任务 |
| 仅定位检查 | `car_bringup/start_relocalization.launch map_id:=<id>` | 仅定位基础栈、自动加载地图和全局重定位 | 建图 launch、第二个全局 TF 发布者 |
| 自主基础栈 | `car_bringup/autonomy.launch` | Livox、FAST-LIO、定位、可选 MAVROS/平台 | 建图 launch、重复传感器和定位节点 |
| 地面规划避障 | `teb_local_planner_tutorials/bz_navigation.launch enable_drone_mode:=false` | 全局路径、局部轨迹、`/navigation/cmd_vel` | 第二个 `move_base` |
| 地面控制 | `ground_air_control/control.launch` | 状态、速度路由、执行器、急停服务 | 第二套控制和执行器节点 |
| 有序任务 | `ground_air_mission/mission.launch` | 任务状态、move_base Action 目标 | 未定位、急停激活、第二个任务执行器 |

建图和重定位不能同时运行。定位 launch 必须在导航期间持续运行；导航 launch 不应重复启动 Livox、FAST-LIO、地图管理或 MAVROS。

## 3. Launch 文件表

### 3.1 系统入口

| Launch | 关键参数/默认值 | 实际行为 | 状态 |
|---|---|---|---|
| `car_bringup/start_mapping.launch` | 必填 `map_id`；`start_stack=true`、`start_mavros=true`、服务等待 90 s | 启动手动建图栈并自动开始记录；成功后保持栈运行 | 正式建图入口 |
| `car_bringup/save_mapping.launch` | 服务等待 15 s | 调用保存地图服务、打印目录/点数/面积后退出 | 正式保存入口 |
| `car_bringup/start_relocalization.launch` | 必填 `map_id`；`start_stack=true`、`start_mavros=false`、重定位超时 60 s | 启动仅定位栈、加载地图并执行全局重定位；成功后保持栈运行 | 正式重定位入口 |
| `car_bringup/manual_mapping.launch` | `start_mavros=true`、`maps_root=/home/bitcq/catkin_ws/maps` | 建图基础栈；不自动开始记录 | 底层入口 |
| `car_bringup/autonomy.launch` | `start_mavros=false`、`start_navigation=false`、`start_control=false`、`start_mission=false` | 包含 `ground_air_full.launch`，默认先定位、不运动 | 自主基础入口 |
| `car_bringup/ground_air_full.launch` | 多个 `start_*` 开关 | 组合全系统；启动本身不解锁、不起飞、不降落 | 通用组合入口 |
| `car_bringup/bringup.launch` | 无 | 旧式组合：地面过滤、动态地图和导航 | 不作为正式全流程入口 |

### 3.2 功能 Launch

| Launch | 关键参数 | 节点/行为 |
|---|---|---|
| `ground_air_mapping/launch/mapping.launch` | `maps_root` | 地图记录器、建图模式 `map → odom` 恒等 TF |
| `ground_air_localization/launch/localization.launch` | `maps_root` | map manager、global relocalizer、全局 TF owner（节点名沿用 `ground_air_world_tf_owner`） |
| `teb_local_planner_tutorials/launch/bz_navigation.launch` | `enable_drone_mode=false`、`navigation_cmd_vel_topic=/navigation/cmd_vel` | `move_base` + GlobalPlanner + TEB |
| `ground_air_control/launch/control.launch` | `takeoff_height=1.0`、控制超时/频率 | mode manager、cmd_vel router、ground actuator |
| `ground_air_mission/launch/mission.launch` | `dwell_seconds=2.0`、`goal_frame=map` | 有序任务执行器 |
| `vision_to_mavros/launch/localization_to_mavros.launch` | `target_frame_id=/map`、`source_frame_id=/body` | 向 MAVROS 提供定位适配 |
| `lukong_fusion_client/launch/lukong_fusion_client.launch` | 由包配置决定 | 点云/里程计关键帧上传 |

### 3.3 `ground_air_full.launch` 开关

| 参数 | 默认值 | 内容 |
|---|---:|---|
| `start_mavros` | false | `mavros/px4.launch` |
| `start_livox` | true | Livox MID360 驱动 |
| `start_fast_lio` | true | FAST-LIO |
| `start_fastlio_odometry_to_px4` | false | `/Odometry` → `/mavros/odometry/out` |
| `start_ground_filter` | true | `pcl_test/filter_ground.launch` |
| `start_dynamic_mapping` | false | 动态 `/map` |
| `start_localization` | true | 地图管理和重定位 |
| `start_navigation` | true | `bz_navigation.launch`，强制地面模式 |
| `start_control` | true | `ground_air_control/control.launch` |
| `start_mission` | true | `ground_air_mission/mission.launch` |
| `start_vision_to_mavros` | true | 定位到 MAVROS |
| `start_fusion_client` | false | 融合客户端 |

实机首次启动不要直接依赖通用入口的运动模块默认值；优先使用 `autonomy.launch` 的保守默认值，分阶段启动导航和控制。

## 4. 核心节点职责

| 节点/可执行程序 | 功能包 | 订阅/输入 | 发布/服务 | TF |
|---|---|---|---|---|
| Livox publisher | `livox_ros_driver2` | MID360 UDP | `/livox/lidar`、`/livox/imu` | 雷达驱动 frame |
| `laserMapping` | `fast_lio_open3d` | Livox 点云、IMU | 注册点云、`/Odometry` | `camera_init → body` |
| `fastlio_odometry_to_px4` | `car_bringup` | `/Odometry` | `/mavros/odometry/out` | 不发布 ROS TF |
| map recorder | `ground_air_mapping` | `/cloud_registered`、`/map` | mapping status 和三项服务 | 建图身份链由 TF owner 管理 |
| `ground_air_map_manager` | `ground_air_localization` | 地图目录 | `/ground_air/load_map`、`/map`、map changed | 否 |
| `ground_air_global_relocalizer` | `ground_air_localization` | 地图 PCD、注册点云、里程计 | valid、pose、fitness、rmse、变换结果 | 不直接抢占全局 TF |
| `ground_air_world_tf_owner` | `ground_air_localization` | 定位有效性和变换结果 | `/tf` | 唯一 `map → odom` |
| `ground_air_operation_node.py` | `car_bringup` | launch 参数、地图/定位服务 | 将真实服务结果输出到 roslaunch | 否 |
| `move_base` | `move_base` | `/map`、TF、里程计、实时点云、目标 | 路径、costmap、`/navigation/cmd_vel` | 否 |
| `ground_air_mode_manager` | `ground_air_control` | MAVROS 状态、空中速度 | VehicleStatus 和控制服务 | 否 |
| `ground_air_cmd_vel_router` | `ground_air_control` | `/navigation/cmd_vel`、VehicleStatus | `/ground/cmd_vel`、`/air/cmd_vel` | 否 |
| `ground_air_ground_actuator` | `ground_air_control` | `/ground/cmd_vel` | `/mavros/actuator_control` | 否 |
| mission executor | `ground_air_mission` | 任务服务、VehicleStatus、定位 | move_base Action、MissionStatus | 否 |

节点的最终 ROS 名称以以下命令确认：

```bash
roslaunch --nodes car_bringup manual_mapping.launch
roslaunch --nodes car_bringup autonomy.launch
roslaunch --nodes teb_local_planner_tutorials bz_navigation.launch enable_drone_mode:=false
```

## 5. 传感器、FAST-LIO 和地图话题

| 话题 | 类型 | 发布者 | 主要消费者 | frame/说明 | 状态 |
|---|---|---|---|---|---|
| `/livox/lidar` | `livox_ros_driver2/CustomMsg` | Livox 驱动 | FAST-LIO | `base_link` | 已接入 |
| `/livox/imu` | `sensor_msgs/Imu` | Livox 驱动 | FAST-LIO | `base_link` | 已接入 |
| `/Laser_map` | `sensor_msgs/PointCloud2` | FAST-LIO | 调试/地图观察 | `camera_init` | 接口已恢复 |
| `/cloud_effected` | `sensor_msgs/PointCloud2` | FAST-LIO | 特征调试 | `camera_init` | 接口已恢复 |
| `/cloud_registered` | `sensor_msgs/PointCloud2` | FAST-LIO | 建图、重定位、平台 | `camera_init` | 已实机验证 |
| `/cloud_registered_body` | `sensor_msgs/PointCloud2` | FAST-LIO | costmap、融合客户端 | `body` | 避障已验证 |
| `/Odometry` | `nav_msgs/Odometry` | FAST-LIO | TEB、重定位、适配器 | parent=`camera_init`、child=`body` | 已实机验证 |
| `/map` | `nav_msgs/OccupancyGrid` | 建图节点或 map_server | move_base、显示 | `map` | 已实机验证 |

2026-08-28 已恢复 FAST-LIO 上游命名。旧 `/Laser_map_1`、`/Odometry_loc`、`/cloud_effected_1`、`/cloud_registered_1`、`/cloud_registered_body_1` 不再属于当前源码契约；如果它们仍在线，说明旧进程尚未重启。`/air/cmd_vel` 和 `/body_frame/path` 是独立接口，保留不变。

检查：

```bash
rostopic hz /livox/lidar
rostopic hz /livox/imu
rostopic hz /cloud_registered
rostopic hz /cloud_registered_body
rostopic hz /Odometry
rostopic echo -n1 /cloud_registered/header
rostopic echo -n1 /Odometry/header
```

## 6. 建图接口

推荐操作入口：

```bash
roslaunch car_bringup start_mapping.launch map_id:=site_20260828_01
# 遥控器低速完成采集后，在另一终端执行：
roslaunch car_bringup save_mapping.launch
```

下列话题和服务是上述 launch 使用的公共底层接口，可用于状态监控和开发排障。

### 6.1 状态话题

`/ground_air/mapping/status`：`ground_air_msgs/MappingStatus`

```text
std_msgs/Header header
uint8 state
string map_id
uint64 point_count
float64 map_area
string message
```

| 值 | 枚举 |
|---:|---|
| 0 | IDLE |
| 1 | RECORDING |
| 2 | SAVING |
| 3 | COMPLETE |
| 4 | ERROR |

### 6.2 服务

| 服务 | 类型 | 请求关键字段 | 响应关键字段 |
|---|---|---|---|
| `/ground_air/mapping/start` | `ground_air_msgs/StartMapping` | `string map_id` | `success`、`message`、`status` |
| `/ground_air/mapping/save` | `ground_air_msgs/SaveMapping` | 空 | `success`、`map_directory`、`point_count`、`map_area`、`status` |
| `/ground_air/mapping/cancel` | `std_srvs/Trigger` | 空 | `success`、`message` |

```bash
rosservice call /ground_air/mapping/start "map_id: 'site_20260827_01'"
rosservice call /ground_air/mapping/save "{}"
rosservice call /ground_air/mapping/cancel "{}"
```

## 7. 地图加载和重定位接口

推荐操作入口：

```bash
roslaunch car_bringup start_relocalization.launch map_id:=site_20260826_01
```

该入口会自动依次调用地图加载和完全未知位姿重定位服务；默认不开 MAVROS、不启动导航、控制或任务执行器。

### 7.1 服务

| 服务 | 类型 | 请求 | 响应 |
|---|---|---|---|
| `/ground_air/load_map` | `ground_air_msgs/LoadMap` | `map_id`、`source_uri` | `success`、`message`、`map_directory` |
| `/ground_air/relocalize` | `ground_air_msgs/Relocalize` | `use_initial_guess`、`initial_guess`、`timeout` | `success`、`message`、`pose`、`fitness`、`rmse` |

完全未知位姿：

```bash
rosservice call /ground_air/load_map "map_id: 'site_20260826_01'
source_uri: ''"

rosservice call /ground_air/relocalize "use_initial_guess: false
initial_guess: {}
timeout: 60.0"
```

### 7.2 话题

| 话题 | 类型 | 含义 |
|---|---|---|
| `/ground_air/localization/map_changed` | `std_msgs/String` | 当前激活 PCD 路径，触发缓存清理/重载 |
| `/ground_air/localization/valid` | `std_msgs/Bool` | 全局定位门控状态 |
| `/ground_air/localization/pose` | `geometry_msgs/PoseStamped` | `map` 下机器人位姿 |
| `/ground_air/localization/fitness` | `std_msgs/Float64` | 配准重叠质量 |
| `/ground_air/localization/rmse` | `std_msgs/Float64` | 内点 RMSE，单位米 |
| `/ground_air/localization/map_to_odom` | `geometry_msgs/TransformStamped` | 重定位解算出的 `map → odom` 变换 |

质量门限：`fitness≥0.55`、`rmse≤0.30 m`、连续 2 次确认、两次差异≤`0.50 m/0.35 rad`。点云超过 2 秒无更新或连续 3 次跟踪失败后 `valid=False`。

## 8. MAVROS、PX4 和遥控器接口

| 话题/服务 | 类型 | 用途 |
|---|---|---|
| `/mavros/state` | `mavros_msgs/State` | 连接、解锁、飞控模式 |
| `/mavros/extended_state` | `mavros_msgs/ExtendedState` | VTOL/着陆扩展状态 |
| `/mavros/rc/in` | `mavros_msgs/RCIn` | 飞控实际接收的遥控器通道 |
| `/mavros/rc/out` | `mavros_msgs/RCOut` | PX4 输出诊断 |
| `/mavros/odometry/out` | `nav_msgs/Odometry` | FAST-LIO 外部里程计送 PX4 |
| `/mavros/local_position/odom` | `nav_msgs/Odometry` | PX4 本地里程计反馈 |
| `/mavros/local_position/pose` | `geometry_msgs/PoseStamped` | PX4 本地位姿反馈 |
| `/mavros/actuator_control` | `mavros_msgs/ActuatorControl` | 地面执行器输出 |
| `/mavros/target_actuator_control` | `mavros_msgs/ActuatorControl` | PX4 目标执行器状态 |
| `/mavros/set_mode` | `mavros_msgs/SetMode` | mode manager 请求 POSCTL/OFFBOARD |

`/mavros/odometry/out` 使用消息 frame `odom/base_link`，仅用于 MAVROS 的标准坐标转换；它不应在 ROS TF 树中引入旧 `odom` 链。

CH5/CH6 已确认典型值：最低约 1050、中间约 1500、最高约 1950。

## 9. 导航和 costmap 接口

| 话题/服务 | 类型 | 方向/用途 |
|---|---|---|
| `/move_base_simple/goal` | `geometry_msgs/PoseStamped` | 单点目标，frame=`map` |
| `/move_base/goal` | `move_base_msgs/MoveBaseActionGoal` | Action 目标 |
| `/move_base/status` | `actionlib_msgs/GoalStatusArray` | Action 状态 |
| `/move_base/result` | `move_base_msgs/MoveBaseActionResult` | Action 结果 |
| `/move_base/feedback` | `move_base_msgs/MoveBaseActionFeedback` | Action 反馈 |
| `/move_base/cancel` | `actionlib_msgs/GoalID` | 取消目标 |
| `/move_base/make_plan` | `nav_msgs/GetPlan` | 只规划、不动车 |
| `/move_base/GlobalPlanner/plan` | `nav_msgs/Path` | 全局路径 |
| `/move_base/TebLocalPlannerROS/local_plan` | `nav_msgs/Path` | 局部轨迹 |
| `/move_base/global_costmap/costmap` | `nav_msgs/OccupancyGrid` | 全局代价地图 |
| `/move_base/local_costmap/costmap` | `nav_msgs/OccupancyGrid` | 局部滚动代价地图 |
| `/navigation/cmd_vel` | `geometry_msgs/Twist` | move_base 经 remap 后输出 |
| `/body_frame/path` | `nav_msgs/Path` | `vision_to_mavros` 轨迹显示接口；本轮保持不变 |

常用 Action 状态：`0=PENDING`、`1=ACTIVE`、`2=PREEMPTED`、`3=SUCCEEDED`、`4=ABORTED`。

精确路径检查必须使用：

```text
tolerance: 0.0
```

## 10. 地面控制接口

### 10.1 VehicleStatus

`/ground_air/vehicle_status`：`ground_air_msgs/VehicleStatus`，锁存发布。当前代码使用字段：

```text
header
mode
connected
armed
localized
emergency_stop
altitude
flight_mode
detail
```

### 10.2 速度链

```text
/navigation/cmd_vel
  → ground_air_cmd_vel_router
  → /ground/cmd_vel
  → ground_air_ground_actuator
  → /mavros/actuator_control
```

| 话题 | 类型 | 说明 |
|---|---|---|
| `/navigation/cmd_vel` | `geometry_msgs/Twist` | 规划器统一输出 |
| `/ground/cmd_vel` | `geometry_msgs/Twist` | 地面安全路由输出 |
| `/air/cmd_vel` | `geometry_msgs/Twist` | 飞行路由输出；地面文档不使用 |
| `/mavros/actuator_control` | `mavros_msgs/ActuatorControl` | `group_mix=1`，controls[3] 前进，controls[2] 反号转向 |

### 10.3 服务

| 服务 | 类型 | 地面模态用途 | 状态 |
|---|---|---|---|
| `/ground_air/emergency_stop` | `ground_air_msgs/SetEmergencyStop` | 急停/解除；解除时确认 OFFBOARD，急停时恢复 POSCTL | 已实机验证 |
| `/ground_air/set_mode` | `ground_air_msgs/SetVehicleMode` | 机械模态请求 | 尚未完整实机验证 |
| `/ground_air/takeoff` | `std_srvs/Trigger` | 自动起飞到默认 1.0 m | 当前禁用 |
| `/ground_air/land` | `std_srvs/Trigger` | 自动降落 | 当前禁用 |

急停请求和响应关键字段：

```text
bool active
---
bool success
string message
ground_air_msgs/VehicleStatus status
```

```bash
rosservice call /ground_air/emergency_stop "active: true"
rosservice call /ground_air/emergency_stop "active: false"
```

## 11. 有序任务接口

| 接口 | 类型 | 作用 | 状态 |
|---|---|---|---|
| `/ground_air/mission/submit` | `ground_air_msgs/SubmitMission` | 提交有序 `PoseStamped[]` | 实机测试未通过 |
| `/ground_air/mission/start` | `std_srvs/Trigger` | 启动任务 | 实机测试未通过 |
| `/ground_air/mission/pause` | `std_srvs/Trigger` | 暂停并停止 | 实机测试未通过 |
| `/ground_air/mission/resume` | `std_srvs/Trigger` | 恢复 | 实机测试未通过 |
| `/ground_air/mission/cancel` | `std_srvs/Trigger` | 取消并停止 | 实机测试未通过 |
| `/ground_air/mission/status` | `ground_air_msgs/MissionStatus` | 任务状态 | 实机测试未通过 |

`SubmitMission` 关键契约：

```text
string mission_id
geometry_msgs/PoseStamped[] goals
---
bool accepted
string message
uint32 goal_count
```

`MissionStatus.state`：`IDLE=0`、`RUNNING=1`、`DWELLING=2`、`PAUSED=3`、`SUCCEEDED=4`、`FAILED=5`、`CANCELED=6`、`WAITING_FOR_LAND=7`。地面任务点停留时间为 2 秒。

2026-08-28 失败记录：障碍环境多点任务发生碰撞；掉头返回任务第二点报告 mission `state=5`、move_base `status=4 (ABORTED)`。这些接口可以调用不等于任务能力已经通过实机验收。

## 12. 平台、融合和视频

| 组件 | 默认输入/行为 | 状态 |
|---|---|---|
| `spiritwing_web` | 已从当前 `catkin_ws/src` 删除 | 不再构建或启动 |
| `lukong_fusion_client` | `/Odometry`、`/cloud_registered_body` 关键帧 HTTP 发送 | 待服务器联调 |
| WebSocket 指控平台和原 RTSP 推流 | 随 `spiritwing_web` 删除 | 当前不可用，后续需新接口重新实现 |

`lukong_fusion_client` 的融合数据上传与已删除的 WebSocket/视频链路不是同一功能。当前不得把“存在融合客户端”表述为“指控平台和视频已可用”。

## 13. TF 树与唯一发布者

### 13.1 建图

```text
map
└── odom              identity，建图 TF owner
    └── camera_init   identity static
        └── body      FAST-LIO dynamic
            └── base_link static
```

### 13.2 重定位和导航

```text
map
└── odom              仅定位有效时，全局 TF owner
    └── camera_init   identity static
        └── body      FAST-LIO dynamic
            └── base_link static
```

### 13.3 TF 责任表

| 边 | 类型 | 唯一发布者 |
|---|---|---|
| `map → odom` | 动态/模式相关 | `ground_air_world_tf_owner` |
| `odom → camera_init` | 静态恒等 | `odom_camera_init_broadcaster` |
| `camera_init → body` | 动态 | FAST-LIO |
| `body → base_link` | 静态 | 安装外参发布器 |

禁止：重新引入 `world` 或 `livox_frame`、第二个 `map → odom` 发布者、重复静态外参、同一 child 多 parent。

### 13.4 检查与导出

```bash
rosrun tf tf_echo map odom
rosrun tf tf_echo odom camera_init
rosrun tf tf_echo camera_init body
rosrun tf tf_echo body base_link
rosrun tf tf_echo map base_link
rosrun tf tf_monitor
rosrun car_bringup export_tf_tree.py
```

导出目录：

```text
/home/bitcq/catkin_ws/artifacts/tf/<时间戳>/frames.gv
/home/bitcq/catkin_ws/artifacts/tf/<时间戳>/frames.pdf
```

## 14. 地图文件与 frame

| 文件 | 生成者 | frame/语义 | 消费者 |
|---|---|---|---|
| `cloud_map.pcd` | `ground_air_mapping` | 建图全局点云，加载后对齐 `map` | Open3D 重定位 |
| `map.pgm` | `ground_air_mapping` | 二维栅格图像 | map_server |
| `map.yaml` | `ground_air_mapping` | resolution、origin、image 等 | map_server |
| `metadata.json` | `ground_air_mapping` | 地图 ID、点数、面积等 | 管理和追溯 |

默认目录：

```text
/home/bitcq/catkin_ws/maps/<map_id>/
```

地图加载要求恰有一个 PCD、一个 YAML，且 YAML 的 image 指向包内存在的图像；同名安装拒绝覆盖。

## 15. 关键导航参数

### 15.1 move_base

| 参数 | 当前值 |
|---|---:|
| `base_global_planner` | `global_planner/GlobalPlanner` |
| `base_local_planner` | `teb_local_planner/TebLocalPlannerROS` |
| `planner_frequency` | 1.0 Hz |
| `controller_frequency` | 5.0 Hz |
| `recovery_behavior_enabled` | false |
| `clearing_rotation_allowed` | false |

### 15.2 GlobalPlanner

| 参数 | 当前值 |
|---|---:|
| `use_dijkstra` | true |
| `allow_unknown` | false |
| `default_tolerance` | 0.25 m |
| `lethal_cost` | 253 |
| `neutral_cost` | 50 |
| `cost_factor` | 3.0 |

`default_tolerance` 是规划器内部参数；实机目标准入仍必须以 `/move_base/make_plan` 的 `tolerance: 0.0` 检查。

### 15.3 TEB

| 参数 | 当前值 |
|---|---:|
| `odom_topic` | `Odometry` |
| `max_vel_x` | 0.1 m/s |
| `max_vel_x_backwards` | 0.1 m/s |
| `max_vel_theta` | 0.2 rad/s |
| `acc_lim_x` | 0.05 m/s² |
| `acc_lim_theta` | 0.2 rad/s² |
| `xy_goal_tolerance` | 0.25 m |
| `yaw_goal_tolerance` | 0.35 rad |
| `min_obstacle_dist` | 0.3 m |
| `inflation_dist` | 0.3 m |
| `include_costmap_obstacles` | true |
| `include_dynamic_obstacles` | false |

### 15.4 Costmap

| 参数 | 当前值 |
|---|---:|
| footprint | 方形，x/y 为 ±0.3 m |
| `transform_tolerance` | 0.2 s |
| obstacle topic | `/cloud_registered_body` |
| obstacle/raytrace range | 5.0/6.0 m |
| obstacle height | 0.15～2.1 m |
| observation persistence | 1.0 s |
| inflation radius | 0.6 m |
| cost scaling factor | 10.0 |
| global static map topic | `/map` |

footprint 四个顶点为 `x/y=±0.30 m`，对应规划尺寸 `0.6 × 0.6 m`，且全局 costmap、局部 costmap、兼容配置和 TEB polygon 必须完全一致。该配置小于此前的 `1.1 × 0.9 m`；如果真实最大外廓更大，规划器会低估碰撞风险，必须保留额外人工安全距离。

## 16. 编译和生效规则

| 修改 | 是否编译 | 何时生效 |
|---|---|---|
| C++ | 是 | 编译、source、重启 |
| Python 内容 | 通常否 | 重启；安装规则变化需编译 |
| `.msg/.srv` | 是 | 先消息包后依赖包，重新 source |
| launch/YAML | 否 | 重启对应节点 |
| TEB/move_base 参数 | 否 | 必须重启 `move_base` |
| 地图包 | 否 | 重新 load_map 和 relocalize |
| FAST-LIO C++ 话题名 | 是 | `catkin_make`、重新 source、结束旧进程并重启 FAST-LIO 及消费者 |

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
catkin_make -j1
source devel/setup.bash
```

2026-08-28 最终远程完整编译通过；注册测试共 71 项，0 failure、0 error。三个新操作 launch 均可展开，`spiritwing_web` 无活动源码、launch 或构建引用；本地与远程抽查的 16 个关键文件校验和一致。话题恢复涉及 FAST-LIO C++，必须重启进程后再用第 5 节命令确认在线名称。

## 17. 常见问题

### 17.1 找不到包、launch 或自定义服务类型

症状：`Unable to load type [ground_air_msgs/SetEmergencyStop]`。

```bash
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash
rospack profile
rossrv show ground_air_msgs/SetEmergencyStop
```

仍失败时先编译 `ground_air_msgs` 和依赖包；不要把服务命令改成错误类型。

### 17.2 Livox 有连接但 FAST-LIO 无输出

```bash
rostopic hz /livox/lidar
rostopic hz /livox/imu
rostopic hz /Odometry
rostopic hz /cloud_registered
```

依次检查雷达网络、IMU、时间戳、FAST-LIO 日志和是否重复启动驱动。

### 17.3 MAVROS 报 `odom_ned` 与 `camera_init` 不在同一 TF 树

检查建图是否启动 `fastlio_odometry_to_px4`：

```bash
rosnode list | grep fastlio_odometry
rostopic echo -n1 /Odometry/header
rostopic echo -n1 /mavros/odometry/out/header
```

预期输入为 `camera_init/body`，输出消息别名为 `odom/base_link`。不要添加旧 ROS TF 链，也不要手工再做 ENU→NED 旋转。

### 17.4 遥控器界面通道变化，但 `/mavros/rc/in` 不变

这说明飞控没有收到对应 SBUS/RC 数据。代码不能制造真实 RC 输入。检查 H16 输出模式、天空端、接线和飞控 RC 端口；修复后再判断 POSITION/解锁问题。

### 17.5 不能切到 POSITION

```bash
rostopic hz /mavros/odometry/out
rostopic echo -n1 /mavros/state
rostopic echo -n1 /mavros/local_position/odom
```

重点检查外部里程计是否持续、新鲜、frame 正确，以及 PX4 estimator 是否接受；不要反复尝试解锁。

### 17.6 地图开始后 `point_count=0`

启动瞬间为 0 正常。持续不增长时：

```bash
rostopic hz /cloud_registered
rostopic echo /ground_air/mapping/status
```

确认已经调用 start、点云 frame 为 `camera_init`、记录器没有 ERROR。

### 17.7 地图保存失败

检查空点云、非法 ID、同名地图、磁盘空间、`/map` 和目录权限：

```bash
df -h /home/bitcq/catkin_ws/maps
ls -la /home/bitcq/catkin_ws/maps
rostopic echo -n1 /map/header
```

不要手动删除同名地图来绕过保护，先确认是否仍需历史数据。

### 17.8 `ground_air_map_manager` 退出

```bash
rosnode info /ground_air_map_manager
roslaunch ground_air_localization localization.launch
```

保存完整终端错误和 ROS 日志。已知 Python 模块安装/导入问题曾被修复；若再次出现，检查是否编译并 source 当前工作空间。

### 17.9 地图加载失败

```bash
ls -lh /home/bitcq/catkin_ws/maps/<map_id>/
grep '^image:' /home/bitcq/catkin_ws/maps/<map_id>/map.yaml
```

必须有 PCD、PGM、YAML，YAML 图片引用必须存在且位于地图包内。

### 17.10 重定位超时或质量失败

检查顺序：

1. 已调用 `/ground_air/load_map`；
2. `/cloud_registered` 新鲜且 frame=`camera_init`；
3. `/Odometry` 新鲜；
4. 机器人静止；
5. 当前区域与历史地图有足够重叠；
6. 场景不应只有重复、对称结构。

不要通过降低质量门限来掩盖地图或输入问题。

### 17.11 `valid` 从 True 变 False

连续 3 次跟踪失败或点云超过 2 秒未更新会自动失效。立即激活急停、取消目标，恢复点云后重新加载地图并重定位。

### 17.12 TF 出现两个不连通树

```bash
rosrun tf tf_echo map odom
rosrun tf tf_echo odom camera_init
rosrun tf tf_echo camera_init body
rosrun tf tf_echo body base_link
rosrun tf tf_monitor
```

FAST-LIO 初始化早期短时缺少 `camera_init → body` 可以等待；持续缺失时修对应发布者。不要增加第三条补偿 TF。

### 17.13 TF 有多 parent 或出现旧 `odom` 链

关闭重复全局定位器、静态发布器或旧 launch。运行：

```bash
rosrun car_bringup export_tf_tree.py
```

导出器会拒绝同一 child 多 parent、缺少目标边和旧 `odom` frame。

### 17.14 move_base 无全局路径

```bash
rostopic echo -n1 /map/header
rosrun tf tf_echo map base_link
rostopic echo -n1 /move_base/global_costmap/costmap
rosservice call /move_base/make_plan "<填入起终点且 tolerance: 0.0>"
```

目标必须在历史地图已知自由区，且不在墙、未知区、地图边界或膨胀层内。

### 17.15 TEB 不发速度

```bash
rostopic echo -n1 /ground_air/localization/valid
rostopic echo /move_base/status
rostopic hz /Odometry
rostopic hz /cloud_registered_body
rostopic echo -n1 /move_base/local_costmap/costmap
```

先查定位、目标、里程计、costmap 和局部轨迹；不要先提高速度或关闭障碍层。

### 17.16 导航时高速原地转圈

立即遥控器接管、激活急停并取消目标：

```bash
rosservice call /ground_air/emergency_stop "active: true"
rostopic pub -1 /move_base/cancel actionlib_msgs/GoalID "{}"
rosparam get /move_base/recovery_behavior_enabled
rosparam get /move_base/clearing_rotation_allowed
```

两个参数必须为 `false`。如果 launch 已改但旧 `move_base` 未重启，旋转恢复插件仍可能存在。还要核对定位航向和目标是否可达。

### 17.17 有 `/navigation/cmd_vel` 但车不动

```bash
rostopic echo -n1 /ground_air/vehicle_status
rostopic echo -n1 /mavros/state
rostopic echo /ground/cmd_vel
rostopic echo /mavros/actuator_control
```

检查急停是否解除、定位是否有效、PX4 是否确认 OFFBOARD、路由是否超时、执行器输出是否非零。

### 17.18 解除急停失败

服务返回 False 时保持停车：

```bash
rostopic echo -n1 /mavros/state
rostopic echo -n1 /ground_air/vehicle_status
rostopic echo -n1 /mavros/actuator_control
```

必须由遥控器完成解锁，地面构型和 telemetry 正常后才能由服务请求 OFFBOARD。

### 17.19 急停后旧目标再次执行

急停阻断速度但不会自动保证所有外部目标都已删除。每次停止都同时取消：

```bash
rostopic pub -1 /move_base/cancel actionlib_msgs/GoalID "{}"
```

解除急停前再次检查 `/move_base/status`。

### 17.20 视频无画面

当前版本已删除 `spiritwing_web` 及其原 RTSP 推流入口，因此没有对应节点或参数可供排查；“无画面”是当前功能边界，不是通过重启现有 launch 可以恢复的故障。后续若恢复实时图像，应重新定义摄像头输入、编码/传输协议、平台鉴权、状态反馈和断线重连，并作为独立功能包验收。

### 17.21 仍看到 `_1` 或 `_loc` 旧 FAST-LIO 话题

2026-08-28 的源码和二进制已经恢复原始名称。旧话题仍在线通常表示修改前启动的进程还在运行：

```bash
rosnode info /fast_lio_node
rostopic list | grep -E 'Laser_map|Odometry|cloud_effected|cloud_registered'
```

保持机器人上锁和软件急停，结束包含旧 FAST-LIO 的 launch，重新 `source ~/catkin_ws/devel/setup.bash` 后只启动一套系统。不得通过同时发布新旧别名掩盖未重启问题。

### 17.22 多点任务 `state=5` 或 move_base `status=4`

`MissionStatus.state=5` 表示任务失败，move_base `status=4` 表示目标被中止。立即急停并取消 Action：

```bash
rosservice call /ground_air/emergency_stop "active: true"
rostopic pub -1 /move_base/cancel actionlib_msgs/GoalID "{}"
```

随后分别对每个任务点执行 `make_plan tolerance=0.0`，检查终点朝向、footprint、膨胀区、全局路径、局部轨迹和 local costmap。现场肉眼看到有路，不能证明带终点姿态的局部轨迹可行。

### 17.23 障碍附近左右摆动或走走停停

该现象已在实机观察到，当前尚未完成 TEB 调参闭环。先停止测试并记录：

```bash
rostopic echo -n1 /move_base/status
rostopic echo -n1 /move_base/GlobalPlanner/plan
rostopic echo -n1 /move_base/TebLocalPlannerROS/local_plan
rostopic echo -n1 /move_base/local_costmap/costmap
```

不要提高速度、关闭障碍层或继续缩小 footprint。后续应结合路径切换、障碍膨胀、TEB 候选轨迹和终点姿态统一调试。

## 18. 完整诊断命令

```bash
cd ~/catkin_ws
source /opt/ros/noetic/setup.bash
source devel/setup.bash

rosnode list | sort
rostopic list | sort
rosservice list | sort

rostopic hz /livox/lidar
rostopic hz /livox/imu
rostopic hz /cloud_registered
rostopic hz /cloud_registered_body
rostopic hz /Odometry
rostopic hz /mavros/odometry/out

rostopic echo -n1 /ground_air/mapping/status
rostopic echo -n1 /ground_air/localization/valid
rostopic echo -n1 /ground_air/localization/fitness
rostopic echo -n1 /ground_air/localization/rmse
rostopic echo -n1 /ground_air/localization/pose
rostopic echo -n1 /ground_air/vehicle_status
rostopic echo -n1 /mavros/state

rosrun tf tf_echo map odom
rosrun tf tf_echo odom camera_init
rosrun tf tf_echo camera_init body
rosrun tf tf_echo body base_link
rosrun tf tf_echo map base_link
rosrun tf tf_monitor

rosparam get /move_base/recovery_behavior_enabled
rosparam get /move_base/clearing_rotation_allowed
rosparam get /move_base/GlobalPlanner
rosparam get /move_base/TebLocalPlannerROS
rosparam get /move_base/global_costmap
rosparam get /move_base/local_costmap
```

## 19. 文档分工

- 本表：公开接口、启动关系、TF、参数和症状式排错。
- 《空地两用机器人地面模态开发文档》：架构、算法、源码职责、编译和验收。
- 《空地两用机器人地面模态自主导航使用手册》：开机后按顺序执行的实机操作。
