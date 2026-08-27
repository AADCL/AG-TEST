# 空地两用无人机 ROS 话题与服务手册

版本：2026-08-27  
ROS：ROS1 Noetic  
工作空间：`/home/bitcq/catkin_ws`

## 1. 使用说明

本文记录当前空地两用无人机主要 ROS 话题、服务、消息类型和诊断命令。

接口状态分为：

- **已实机验证**：建图、地图加载、未知位姿重定位、地面单点自主导航、TEB 实时避障、地面执行器和软件急停闭环。
- **代码已实现、待完整实机验收**：有序多任务点、自动起飞/降落、飞行自主导航、平台控制和视频链路。

查看当前机器实际接口时，以以下命令为准：

```bash
rostopic list
rosservice list
rosnode list
```

## 2. 传感器、FAST-LIO 与地图话题

| 话题 | 消息类型 | 主要发布者 | 用途 | 状态 |
|---|---|---|---|---|
| `/livox/lidar` | `livox_ros_driver2/CustomMsg` | Livox 驱动 | Livox 原始雷达数据 | 已接入 |
| `/cloud_registered_1` | `sensor_msgs/PointCloud2` | FAST-LIO | `camera_init` 下注册点云，供建图、重定位、Web 地图上传 | 已实机验证 |
| `/cloud_registered_body_1` | `sensor_msgs/PointCloud2` | FAST-LIO | 机体系点云，供导航代价地图障碍层和多机器人关键帧融合使用 | 导航避障输入已实机验证，融合待联调 |
| `/Odometry_loc` | `nav_msgs/Odometry` | FAST-LIO | 当前局部里程计，默认 `camera_init` 坐标系 | 已实机验证 |
| `/map` | `nav_msgs/OccupancyGrid` | 建图时为动态建图节点；重定位时为 map_server | 二维栅格地图 | 已实机验证 |

常用检查：

```bash
rostopic type /cloud_registered_1
rostopic echo -n1 /cloud_registered_1/header
rostopic hz /cloud_registered_1

rostopic type /Odometry_loc
rostopic echo -n1 /Odometry_loc/header
rostopic hz /Odometry_loc

rostopic echo -n1 /map/header
```

建图和重定位要求 `/cloud_registered_1/header/frame_id` 为 `camera_init`。

## 3. 地图记录话题

### `/ground_air/mapping/status`

- 类型：`ground_air_msgs/MappingStatus`
- 发布者：`ground_air_mapping/map_recorder_node`
- 发布方式：锁存状态话题
- 内容：地图状态、地图 ID、累计点数、面积和状态说明

字段：

```text
std_msgs/Header header
uint8 state
string map_id
uint64 point_count
float64 map_area
string message
```

状态枚举：

| 值 | 名称 | 说明 |
|---:|---|---|
| 0 | IDLE | 空闲 |
| 1 | RECORDING | 正在记录 |
| 2 | SAVING | 正在保存 |
| 3 | COMPLETE | 保存完成 |
| 4 | ERROR | 错误 |

查看：

```bash
rostopic echo /ground_air/mapping/status
```

## 4. 重定位话题

| 话题 | 消息类型 | 含义 | 成功标准 |
|---|---|---|---|
| `/ground_air/localization/valid` | `std_msgs/Bool` | 当前全局定位是否有效 | 必须为 `True` |
| `/ground_air/localization/pose` | `geometry_msgs/PoseStamped` | 机器人在历史地图中的位姿 | `frame_id=world` |
| `/ground_air/localization/fitness` | `std_msgs/Float64` | 点云匹配重叠质量 | `>= 0.55` |
| `/ground_air/localization/rmse` | `std_msgs/Float64` | 匹配内点均方根误差，单位米 | `<= 0.30` |
| `/ground_air/localization/map_to_odom` | `geometry_msgs/TransformStamped` | 重定位解算出的 `world -> camera_init` 变换 | 供唯一 TF 所有者使用 |

查看：

```bash
rostopic echo -n1 /ground_air/localization/valid
rostopic echo -n1 /ground_air/localization/pose
rostopic echo -n1 /ground_air/localization/fitness
rostopic echo -n1 /ground_air/localization/rmse
```

说明：

- 地图刚加载时 `valid=False` 是正常的。
- 重定位成功后才变为 `True`。
- 连续 3 次跟踪失败或注册点云超过 2 秒未更新时，会自动变回 `False`。
- 自主任务必须以该状态作为启动和继续运行的门控条件。

## 5. TF 话题和目标树

| 话题 | 类型 | 用途 |
|---|---|---|
| `/tf` | `tf2_msgs/TFMessage` | 动态坐标变换 |
| `/tf_static` | `tf2_msgs/TFMessage` | 静态外参变换 |

目标主链：

```text
world
└── camera_init
    └── body
        └── base_link
            └── livox_frame
```

所有权：

- `world -> camera_init`：`ground_air_world_tf_owner`
- `camera_init -> body`：FAST-LIO
- `body -> base_link -> livox_frame`：静态外参发布器

定位模式下，只有 `/ground_air/localization/valid=True` 时才发布 `world -> camera_init`。

常用检查：

```bash
rosrun tf tf_echo world camera_init
rosrun tf tf_echo world base_link
rosrun tf view_frames
```

系统中不得重新出现旧的 `world -> odom -> camera_init` 链，也不得有两个节点同时发布同一个 child frame。

## 6. MAVROS、PX4 与遥控器话题

| 话题 | 消息类型 | 用途 |
|---|---|---|
| `/mavros/state` | `mavros_msgs/State` | PX4 连接、解锁状态和飞行模式 |
| `/mavros/rc/in` | `mavros_msgs/RCIn` | 飞控实际接收到的遥控器通道值 |
| `/mavros/rc/out` | `mavros_msgs/RCOut` | PX4 当前地面执行混控输出，供实机诊断 |
| `/mavros/odometry/out` | `nav_msgs/Odometry` | 将 FAST-LIO 视觉/激光里程计送给 MAVROS/PX4 |
| `/mavros/local_position/odom` | `nav_msgs/Odometry` | PX4/MAVROS 本地里程计反馈 |
| `/mavros/local_position/pose` | `geometry_msgs/PoseStamped` | PX4 本地位姿反馈 |
| `/mavros/extended_state` | `mavros_msgs/ExtendedState` | 着陆状态等扩展状态 |
| `/mavros/actuator_control` | `mavros_msgs/ActuatorControl` | 软件地面执行器输出，手动建图时默认不使用 |
| `/mavros/target_actuator_control` | `mavros_msgs/ActuatorControl` | MAVROS/PX4 侧目标执行器状态，供链路诊断 |

查看连接和解锁状态：

```bash
rostopic echo -n1 /mavros/state
```

重点字段：

```text
connected: True
armed: True/False
mode: "..."
```

查看遥控器通道：

```bash
rostopic echo /mavros/rc/in
```

当前 H16 遥控器已确认：

```text
CH5/CH6 最低约 1050
CH5/CH6 中间约 1500
CH5/CH6 最高约 1950
```

判断原则：遥控器界面中的通道变化不等于飞控已经收到；必须以 `/mavros/rc/in` 中对应通道的变化为准。

检查送往 PX4 的里程计：

```bash
rostopic echo -n1 /mavros/odometry/out
rostopic hz /mavros/odometry/out
```

FAST-LIO 原始坐标使用 ENU/FLU 语义；MAVROS 负责向 PX4 所需 NED/FRD 语义转换。不要在上游再重复做一次 ENU 到 NED 转换。

## 7. 控制、导航和任务话题

地面单点自主导航和实时避障已完成实机验证；有序多任务点和飞行全过程仍需后续验收。

| 话题 | 类型 | 方向 | 用途 |
|---|---|---|---|
| `/ground_air/vehicle_status` | `ground_air_msgs/VehicleStatus` | 状态输出 | 模态、连接、解锁、定位、急停、高度等综合状态 |
| `/navigation/cmd_vel` | `geometry_msgs/Twist` | 导航输入 | 导航器或任务执行器的统一速度指令 |
| `/ground/cmd_vel` | `geometry_msgs/Twist` | 地面输出 | 路由后的地面速度指令 |
| `/air/cmd_vel` | `geometry_msgs/Twist` | 飞行输出 | 路由后的定高飞行平面速度指令 |
| `/ground_air/mission/status` | `ground_air_msgs/MissionStatus` | 状态输出 | 有序任务点执行状态 |
| `/move_base_simple/goal` | `geometry_msgs/PoseStamped` | 导航目标 | 单个 move_base 目标点 |
| `/move_base/cancel` | `actionlib_msgs/GoalID` | 导航控制 | 取消当前或全部 move_base 目标 |
| `/move_base/status` | `actionlib_msgs/GoalStatusArray` | 状态输出 | 目标接收、执行、成功或失败状态 |
| `/move_base/GlobalPlanner/plan` | `nav_msgs/Path` | 规划输出 | 当前全局路径 |
| `/move_base/TebLocalPlannerROS/local_plan` | `nav_msgs/Path` | 规划输出 | TEB 当前局部轨迹 |
| `/move_base/global_costmap/costmap` | `nav_msgs/OccupancyGrid` | 导航输入/诊断 | 历史地图与实时障碍融合后的全局代价地图 |
| `/move_base/local_costmap/costmap` | `nav_msgs/OccupancyGrid` | 导航输入/诊断 | 机器人周围滚动局部代价地图 |

速度路由规则：

```text
/navigation/cmd_vel
        |
        +-- 地面模态 --> /ground/cmd_vel
        |
        +-- 飞行模态 --> /air/cmd_vel
```

急停、未知模态、模态切换中或指令超时时，路由器应输出零速度。

当前已验证的地面执行链为：

```text
/move_base
  -> /navigation/cmd_vel
  -> ground_air_cmd_vel_router
  -> /ground/cmd_vel
  -> ground_air_ground_actuator
  -> /mavros/actuator_control
  -> PX4（仅 OFFBOARD 接受外部直接执行器控制）
```

地面执行器使用 `group_mix=1`，当前映射为：

```text
controls[3] = clamp(linear.x, -1, 1)
controls[2] = clamp(-angular.z, -1, 1)
```

保守实机参数：`max_vel_x=0.1 m/s`、`max_vel_theta=0.2 rad/s`。`move_base` 的旋转恢复和清图旋转已关闭；不可规划时应停车。

查看：

```bash
rostopic echo /ground_air/vehicle_status
rostopic echo /ground_air/mission/status
rostopic echo /navigation/cmd_vel
rostopic echo /ground/cmd_vel
rostopic echo /move_base/status
rostopic echo -n1 /move_base/local_costmap/costmap/header
```

## 8. 地图服务

### `/ground_air/mapping/start`

- 类型：`ground_air_msgs/StartMapping`
- 作用：以新的地图 ID 开始记录

```bash
rosservice call /ground_air/mapping/start "map_id: 'site_20260826_01'"
```

### `/ground_air/mapping/save`

- 类型：`ground_air_msgs/SaveMapping`
- 作用：保存当前记录，生成 PCD、PGM、YAML 和元数据

```bash
rosservice call /ground_air/mapping/save "{}"
```

### `/ground_air/mapping/cancel`

- 类型：`std_srvs/Trigger`
- 作用：取消当前未保存记录并清理缓存

```bash
rosservice call /ground_air/mapping/cancel "{}"
```

## 9. 重定位服务

### `/ground_air/load_map`

- 类型：`ground_air_msgs/LoadMap`
- 作用：校验并激活历史地图包，同时启动 map_server 发布 `/map`

```bash
rosservice call /ground_air/load_map "map_id: 'site_20260826_01'
source_uri: ''"
```

`source_uri: ''` 表示从本机 `/home/bitcq/catkin_ws/maps/<map_id>` 加载。

### `/ground_air/relocalize`

- 类型：`ground_air_msgs/Relocalize`
- 作用：执行 FPFH/RANSAC 全局匹配和点到面 ICP 精配准

完全未知初始位姿：

```bash
rosservice call /ground_air/relocalize "use_initial_guess: false
initial_guess: {}
timeout: 60.0"
```

响应字段：

```text
bool success
string message
geometry_msgs/PoseStamped pose
float64 fitness
float64 rmse
```

## 10. 模态和安全服务

以下服务会影响真实硬件，只有在相应控制栈已启动、现场完成安全检查且操作者明确授权时才能调用。

| 服务 | 类型 | 作用 | 当前状态 |
|---|---|---|---|
| `/ground_air/takeoff` | `std_srvs/Trigger` | 切到飞行模态并起飞至默认 1.0 m | 代码已实现，待飞行验收 |
| `/ground_air/land` | `std_srvs/Trigger` | 自动降落并切回地面模态 | 代码已实现，待飞行验收 |
| `/ground_air/set_mode` | `ground_air_msgs/SetVehicleMode` | 请求地面/飞行机械模态切换 | 待完整实机验收 |
| `/ground_air/emergency_stop` | `ground_air_msgs/SetEmergencyStop` | 激活或解除软件急停 | 地面模态闭环已实机验证，不能替代遥控器安全措施 |

控制节点启动时默认执行启动安全闭锁：

```text
emergency_stop = True
```

激活软件急停：

```bash
rosservice call /ground_air/emergency_stop "active: true"
```

解除急停前必须确认故障原因已经排除：

```bash
rosservice call /ground_air/emergency_stop "active: false"
```

地面构型且已解锁时，解除急停会先请求并确认 PX4 `OFFBOARD`，确认成功后才向路由器发布 `emergency_stop=False`。成功消息为：

```text
operator reset; ground OFFBOARD confirmed
```

重新激活急停时，控制链先发布零输出，等待执行器归零，再把 PX4 恢复为 `POSCTL`。成功消息为：

```text
operator emergency stop; POSCTL restored
```

服务返回 `False` 时不得反复解除急停，应保持车辆停止并检查 `/mavros/state`、`/ground_air/vehicle_status` 和执行器输出。

## 11. move_base 标准导航接口

### `/move_base/make_plan`

- 类型：`nav_msgs/GetPlan`
- 作用：在不启动车辆的情况下检查起点到目标点是否存在全局路径
- 实机规则：目标点必须使用 `tolerance: 0.0` 做精确终点检查

精确终点无路径时，不得使用较大容差强行接受邻近栅格并解除急停。物理现场看似开阔，但历史地图中的未知区、地图边界、墙体或膨胀层仍可能使目标不可达。

### `/move_base_simple/goal`

发布单个 `world` 坐标系目标：

```bash
rostopic pub -1 /move_base_simple/goal geometry_msgs/PoseStamped "
header:
  frame_id: 'world'
pose:
  position: {x: <目标X>, y: <目标Y>, z: 0.0}
  orientation: {x: 0.0, y: 0.0, z: <目标QZ>, w: <目标QW>}"
```

建议在软件急停保持 `True` 时先发布目标并检查状态，再调用 `/ground_air/emergency_stop` 解除急停。

### `/move_base/status`

常用 action 状态：

| 值 | 含义 |
|---:|---|
| 0 | 等待处理 |
| 1 | 正在执行 |
| 2 | 被抢占 |
| 3 | 成功到达 |
| 4 | 规划或控制失败 |

### `/move_base/cancel`

取消全部目标：

```bash
rostopic pub -1 /move_base/cancel actionlib_msgs/GoalID "{}"
```

正常停止先取消目标，再激活软件急停；紧急情况先急停，再取消目标。必须清除旧目标，防止以后解除急停时旧任务继续执行。

## 12. 任务服务

| 服务 | 类型 | 作用 | 状态 |
|---|---|---|---|
| `/ground_air/mission/submit` | `ground_air_msgs/SubmitMission` | 提交一组有序任务点 | 代码已实现，待平台联调 |
| `/ground_air/mission/start` | `std_srvs/Trigger` | 启动已提交任务 | 待导航实机验收 |
| `/ground_air/mission/pause` | `std_srvs/Trigger` | 暂停任务并停止/悬停 | 待导航实机验收 |
| `/ground_air/mission/resume` | `std_srvs/Trigger` | 恢复任务 | 待导航实机验收 |
| `/ground_air/mission/cancel` | `std_srvs/Trigger` | 取消任务并发送停止指令 | 待导航实机验收 |

任务执行器约束：

- 未定位或急停激活时拒绝任务。
- 任务点按顺序执行。
- 地面模态到达每个任务点后停留 2 秒。
- 飞行模态到达任务点后保持悬停，不自动降落，等待平台降落指令。

## 13. 指控平台、融合和视频接口

- `spiritwing_web`：负责 WebSocket 指控平台适配；当前部分真实平台自定义消息仍需后续补齐和联调。
- `lukong_fusion_client`：默认订阅 `/Odometry_loc` 与 `/cloud_registered_body_1`，生成关键帧并通过 HTTP 发送给融合服务器。
- 实时视频当前采用 RTSP/推流链路，不一定表现为 ROS 图像话题；是否启动由 `start_video` 和相应摄像头参数控制。

手动建图 launch 当前会启用融合客户端，但平台或融合服务器未连接时不应影响本地地图记录服务的使用。

## 14. 通用诊断命令

### 查找话题类型和连接关系

```bash
rostopic type /cloud_registered_1
rostopic info /cloud_registered_1
rosmsg show sensor_msgs/PointCloud2
```

### 查找服务类型和字段

```bash
rosservice type /ground_air/relocalize
rossrv show ground_air_msgs/Relocalize
rosservice info /ground_air/relocalize
```

若出现 `Unable to load type [ground_air_msgs/...]`，说明当前终端没有加载新工作空间：

```bash
source /opt/ros/noetic/setup.bash
source ~/catkin_ws/devel/setup.bash
rossrv show ground_air_msgs/SetEmergencyStop
```

每个新终端都必须重新加载上述环境。

### 检查节点

```bash
rosnode list
rosnode info /ground_air_map_manager
rosnode info /ground_air_global_relocalizer
```

### 检查频率和延迟

```bash
rostopic hz /cloud_registered_1
rostopic hz /Odometry_loc
rostopic delay /cloud_registered_1
```

### 检查定位健康状态

```bash
rostopic echo -n1 /ground_air/localization/valid
rostopic echo -n1 /ground_air/localization/fitness
rostopic echo -n1 /ground_air/localization/rmse
rosrun tf tf_echo world camera_init
```

### 检查地面导航安全状态

```bash
rostopic echo -n1 /ground_air/vehicle_status
rostopic echo -n1 /mavros/state
rostopic echo -n1 /mavros/actuator_control
rosparam get /move_base/recovery_behavior_enabled
rosparam get /move_base/clearing_rotation_allowed
rosparam get /move_base/TebLocalPlannerROS/max_vel_x
rosparam get /move_base/TebLocalPlannerROS/max_vel_theta
```

自主导航前必须完成地图加载和全局重定位；`localization/valid=True` 只表示跟踪状态有效，机器人重新开机、切换地图或被搬动后仍必须重新执行 `/ground_air/relocalize`。

### 导出当前接口清单

```bash
mkdir -p ~/artifacts/ros_interfaces
rostopic list -v > ~/artifacts/ros_interfaces/topics.txt
rosservice list > ~/artifacts/ros_interfaces/services.txt
rosnode list > ~/artifacts/ros_interfaces/nodes.txt
```
