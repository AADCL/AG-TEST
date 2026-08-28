# SpiritWing 路空无人机 Web 接入包

该包用于把第三方指控系统 WebSocket 协议接入路空 SpiritWing 无人机。

当前资料只有 `ROS2无人机接入指控系统信息清单-路空.xlsx`，未提供
`swing_msgs/UAVCommand`、`swing_msgs/UIState`、`swing_msgs/PatrolState`
等消息定义。因此本包先实现可编译的 ROS1 Noetic 框架，并把依赖未知消息的
控制链路做成可替换适配层。

## 已实现

- WebSocket 连接指控平台。
- `robot_status` 周期上报。
- `multi_goal_down` 缓存平台任务点。
- `navigation_start_down` 默认发布首个目标点到 `/move_base_simple/goal`。
- `navigation_pause_down` / `navigation_resume_down` / `navigation_stop_down` 基础响应。
- `relocalize_pose_down` 发布 `/initialpose`。
- `manual_control_down`、`takeoff_down`、`land_down`、`emergency_stop_down` 转成 JSON 占位命令。
- 可选 MAVROS 兜底控制后端。
- 可选 `/move_base_simple/goal` 导航后端。
- 可选 `/cmd_vel` 手控后端，配合 `scripts/cmd_vel_to_actuator_control.py` 转 `/mavros/actuator_control`。

## 编译

```bash
cd ~/spiritwing_web_ws
catkin_make
source devel/setup.bash
```

依赖：

```bash
sudo apt install -y ros-noetic-mavros-msgs libyaml-cpp-dev nlohmann-json3-dev
```

`libhv` 需要按现场已有方式安装到 `/usr/local` 或系统库路径。

## 启动

```bash
roslaunch spiritwing_web spiritwing_web.launch
```

## 现场导航/手控接口

`spiritwing_info_19700101_081820` 已确认当前真机导航使用：

```bash
rostopic pub /move_base_simple/goal geometry_msgs/PoseStamped ...
```

当前 `config/params.yaml` 默认已经是：

```yaml
spiritwing_node:
  navigation_backend: "move_base_simple"
```

如果需要同时给原 `/spiritwing/patrol_points` 和 `/move_base_simple/goal` 发目标点，用：

```yaml
spiritwing_node:
  navigation_backend: "both"
```

如果现场手控链路是 `/cmd_vel -> /mavros/actuator_control`，启动转换脚本：

```bash
roslaunch spiritwing_web cmd_vel_to_actuator_control.launch
```

再把 `config/params.yaml` 改为：

```yaml
spiritwing_node:
  command_backend: "cmd_vel"
```

此时 Web 模块的手控会发布 `/cmd_vel`，脚本再按现场映射写入 `/mavros/actuator_control`。

本次采集还确认：

- 默认位姿使用 FAST-LIO 原始接口 `/Odometry`，兜底为 `/mavros/local_position/odom`。
- `/livox/lidar` 是 `livox_ros_driver2/CustomMsg`，默认点云上传 topic 使用 `/cloud_registered`。
- `/map` 是 `nav_msgs/OccupancyGrid`，由 `/dynamic_mapping` 发布并被 `/move_base` 使用。

## 真机信息采集脚本

在补齐 `swing_msgs` 和真实 topic 前，先在路空无人机真机上运行只读采集脚本：

```bash
cd ~/spiritwing_web_ws
source devel/setup.bash

bash "$(rospack find spiritwing_web)/scripts/collect_spiritwing_info.sh"
```

也可以指定输出目录：

```bash
bash "$(rospack find spiritwing_web)/scripts/collect_spiritwing_info.sh" /tmp/spiritwing_info
```

脚本不会发布控制指令，不会解锁、起飞、降落或切换模式。它会采集：

- `swing_msgs/UAVCommand`、`swing_msgs/PatrolState` 等消息定义。
- `/spiritwing/command`、`/spiritwing/patrol_points`、`/spiritwing/patrol_state`。
- `/spiritwing/state`、`/spiritwing/control_state`、`/spiritwing/sensor_state`、`/spiritwing/ui_state` 等状态 topic。
- `/Odometry`、`/spiritwing/oodm`、`/spiritwing/odom`、`/mavros/local_position/odom`。
- `/livox/lidar`、`/livox/cloud_in_world`、`/Laser_map`、`/cloud_registered`、`/cloud_registered_body` 等点云/地图 topic。
- MAVROS 状态、电池、本地位姿/速度、GPS、RC、IMU、service、参数、TF。
- `step0_sensor.sh`、`step1_getMap.sh`、`step2_mission.sh`、`start*.sh`、`cmd_mavros.py` 等启动/控制脚本路径和内容。
- 全部 ROS topic/service 类型表，便于发现资料未写的接口。
- 可能的地图文件路径，以及 `/pub_map`、`/save_map`、`/save_pose`、`/send_map_srv` 等地图相关 service。

运行完成后，把输出目录整体发回用于继续补齐真实控制和状态解析。

## 后续拿到真机后必须补齐

1. `rosmsg show swing_msgs/UAVCommand`
2. `rosmsg show swing_msgs/UIState`
3. `rosmsg show swing_msgs/PatrolState`
4. `rosmsg show swing_msgs/SensorState`

拿到上述定义后，应把 `json_placeholder` 后端替换成真正的
`/spiritwing/command` 自定义消息发布。
