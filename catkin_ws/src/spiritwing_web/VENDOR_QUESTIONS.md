# 路空 SpiritWing 无人机厂家待确认信息清单

本文只针对 `ROS2无人机接入指控系统信息清单-路空.xlsx`。  
注意：不要混用另一份“涵道”无人机资料。

当前资料已经给出了一部分接入信息，下面先列“已知信息”，再列真正还需要厂家补充确认的内容。

## 1. 路空资料已给出的信息

### 1.1 系统环境

- ROS 版本：`ROS Noetic`
- Ubuntu / 架构：`Ubuntu 20.04 arm64`
- 飞控类型：`PX4`
- 飞控桥接：`MAVROS`
- 机载工作空间路径：`~/spritwing_v1.0`
- RMW/DDS：无
- 设备访问 WebSocket：资料写“否”
- 设备访问文件上传接口：资料写“否”

### 1.2 状态、定位、坐标系

- 飞控连接状态：`/mavros/state`
- 解锁状态：`/mavros/state`
- 飞行模式：`/mavros/state`
- 地面/空中状态来源：资料写“遥控器设置模式”
- 电池状态：`/mavros/battery`
- 当前位置/姿态：`/Odometry`
- 定位输出：`/Odometry`
- TF 关系：`world -> odom -> base_link -> lidar_link`
- 指控系统任务点 frame：`world`

### 1.3 手动控制

- 推荐控制接口：向 `/spiritwing/command` 发布 `swing_msgs::UAVCommand`
- 控制坐标系：`base_link`
- 推荐发布频率：`30-50Hz`
- 手动控制需要的飞控模式：`自稳、定点`
- 速度/加速度上限：资料只写 `max_vel, max_acc`

### 1.4 起飞、降落、悬停、安全

- 起飞接口：`CONTROL_STATE::COMMAND_CONTROL`，`Init_Pos_Hover`
- 降落接口：向 `/spiritwing/command` 发送 `swing_msgs::UAVCommand::Land`
- 悬停接口：`Current_Pos_Hover`
- 返航接口：资料写“无”
- 急停/任务中止：遥控器急停拨杆
- 控制权切换：遥控器切换模式
- 最小起飞高度：`0.3m`
- 最大速度：资料写 `8m/s`
- 低电量策略：低电量自动降落

### 1.5 建图、地图、重定位

- 雷达型号：`Mid360`
- 原始点云：`/livox/lidar`
- 点云 frame / 单位：`/livox_frame`，米
- 点云频率：`10Hz`
- 建图算法：`fast_lio2`
- 启动建图接口：资料写“无”
- 停止建图接口：资料写“无”
- 地图保存路径：资料写“否”
- 原生生成 PCD：资料写“否”
- 原生生成 `map.pgm` / `map.yaml`：资料写“是”
- 全局地图点云 topic：资料写“否”
- 历史地图加载接口：资料写“否”
- 当前地图状态反馈：资料写“否”
- 设置初始位姿接口：资料写“否”
- 重定位成功/失败反馈：资料写“否”

### 1.6 导航任务

- 导航目标入口：`/spiritwing/patrol_points`
- 导航目标类型：`nav_msgs/Path`
- 多目标任务：支持，仍为 `/spiritwing/patrol_points` + `nav_msgs/Path`
- 暂停导航接口：同悬停，即 `Current_Pos_Hover`
- 恢复导航接口：资料写“无”
- 停止/取消导航接口：同悬停，即 `Current_Pos_Hover`
- 导航反馈：`/spiritwing/patrol_state`
- 导航反馈类型：`swing_msgs::PatrolState`
- 轨迹输出：资料写 `/spiritwing/oodm`，类型 `nav_msgs::Odometry`
- 导航允许条件：定位准确、飞控正常、遥控器连接正常
- 是否原生支持自主探索建图：否
- 避障状态 topic：无

### 1.7 启动流程和常驻节点

资料给出的启动顺序：

- 正常飞行：`step0_sensor.sh -> step1_getMap.sh`
- 建图：`step0_sensor.sh -> step1_getMap.sh`
- 定位导航：`step0_sensor.sh -> step2_mission.sh`

资料给出的常驻不可停止节点：

```text
/ground_control_1
/livox_broadcaster_1
/livox_lidar_publisher2_1
/mavros
/rosout
/swarm_bridge_node
/tfmini_ros_node_0
```

资料给出的可由 Web 启停节点：剩余节点可以。

## 2. 仍需厂家补充的关键信息

### 2.1 必须提供 `swing_msgs` 消息定义

当前 Web 模块无法真正发布 `/spiritwing/command`，核心原因是没有自定义消息定义。请厂家提供源码包，或直接给出以下命令输出：

```bash
rosmsg show swing_msgs/UAVCommand
rosmsg show swing_msgs/PatrolState
```

如果 `/spiritwing/state`、`/spiritwing/sensor_state` 或其他状态 topic 使用自定义消息，也请一并提供：

```bash
rosmsg show <真实状态消息类型>
```

### 2.2 `/spiritwing/command` 字段和枚举

资料已经写明控制入口是 `/spiritwing/command` + `swing_msgs::UAVCommand`，但缺少字段细节。请补充：

- `CONTROL_STATE::COMMAND_CONTROL` 对应哪个字段、具体数值是多少。
- `Init_Pos_Hover` 对应哪个字段、具体数值是多少。
- `Current_Pos_Hover` 对应哪个字段、具体数值是多少。
- `swing_msgs::UAVCommand::Land` 对应哪个字段、具体数值是多少。
- 手动速度控制时，前后、左右、上下、偏航角速度分别写入哪些字段。
- `max_vel`、`max_acc` 的具体数值和单位。
- 角速度上限是多少。

### 2.3 请给出可直接执行的控制示例

请提供以下 `rostopic pub` 示例，便于 Web 模块完全复刻：

```bash
rostopic pub /spiritwing/command swing_msgs/UAVCommand "..."
```

需要示例：

- 起飞到默认高度。
- 悬停。
- 降落。
- 前进。
- 后退。
- 左转。
- 右转。
- 上升。
- 下降。
- 停止手动控制。

### 2.4 飞行状态判断仍不够

资料写状态主要来自 `/mavros/state`、`/mavros/battery`、`/Odometry`，但没有明确“地面/空中”的可编程判断字段。请补充：

- Web 模块应该如何判断无人机已经起飞成功。
- Web 模块应该如何判断无人机在地面。
- Web 模块应该如何判断正在降落或已经降落完成。
- “遥控器设置模式”具体如何从 ROS topic 中读到。
- 导航允许条件中的“定位准确、飞控正常、遥控器连接正常”分别对应哪些字段。

请提供以下样例输出：

```bash
rostopic echo -n 1 /mavros/state
rostopic echo -n 1 /mavros/extended_state
rostopic echo -n 1 /Odometry
```

分别在地面、空中悬停、导航中、降落后各提供一份。

### 2.5 `/spiritwing/patrol_state` 反馈细节

资料给出了 `/spiritwing/patrol_state` + `swing_msgs::PatrolState`，但没有字段定义。请补充：

- 到达单个目标点如何判断。
- 所有目标完成如何判断。
- 导航失败如何判断。
- 当前执行到第几个目标点如何判断。
- 任务停止/暂停后会不会有反馈。

请提供：

```bash
rosmsg show swing_msgs/PatrolState
rostopic echo /spiritwing/patrol_state
```

最好覆盖：执行中、到点、任务完成、失败四种状态。

### 2.6 `/spiritwing/oodm` 是否拼写正确

资料中的轨迹输出写为：

```text
/spiritwing/oodm
nav_msgs::Odometry
```

请确认 topic 是否确实叫 `/spiritwing/oodm`，还是 `/spiritwing/odom`。

### 2.7 地图文件路径仍缺失

资料写：

- 原生 PCD：否
- 原生 `map.pgm/map.yaml`：是
- 地图保存路径：否

请补充：

- `map.pgm` 和 `map.yaml` 的真实保存目录。
- 文件名是否固定。
- 停止建图后是否自动保存。
- 是否需要调用 `/save_map`、`/pub_map`、`/send_map_srv` 等 service。
- 如果没有 PCD，平台需要 `cloud_map.pcd` 时推荐从哪个 topic 或文件生成。

请提供一次建图完成后的目录输出：

```bash
ls -lah <地图输出目录>
```

### 2.8 建图启动/停止流程

资料写建图启动接口和停止接口都是“无”，但启动流程又写了 `step1_getMap.sh`。请确认：

- 点击指控系统 `slam_start_down` 时，Web 是否需要执行 `step1_getMap.sh`。
- 点击指控系统 `slam_stop_down` 时，Web 是否需要停止某些节点或调用保存服务。
- `step0_sensor.sh`、`step1_getMap.sh`、`step2_mission.sh` 的完整路径。
- 这些脚本能否被 Web 自动执行。
- 执行脚本前是否需要 source 某个环境。

### 2.9 历史地图和重定位

资料写历史地图加载、初始位姿、重定位反馈均为“否”。请确认：

- 路空无人机是否支持加载历史地图后定位导航。
- 如果支持，历史地图应该放到哪个目录。
- 是否支持 `/initialpose`。
- 如果不支持 `/initialpose`，应该如何完成重定位。
- 重定位成功后从哪个 topic 判断。

### 2.10 返航和急停

资料写返航接口为“无”，急停为遥控器急停拨杆。请确认：

- 指控系统控制中心“返航”按钮是否无法接入。
- 是否存在 PX4 RTL 或厂家自定义返航接口。
- Web 是否允许触发急停，还是只能人工使用遥控器急停拨杆。
- 遥控器急停后，ROS 侧是否有状态反馈。

## 3. 推荐厂家直接提供的最小资料包

为了减少反复沟通，建议厂家直接提供：

- `swing_msgs` ROS 包源码。
- `/spiritwing/command` 起飞、悬停、降落、手控、停止的最小 demo。
- `/spiritwing/patrol_points` 导航到点 demo。
- `/spiritwing/patrol_state` 执行中、到点、完成、失败样例。
- `step0_sensor.sh`、`step1_getMap.sh`、`step2_mission.sh` 脚本路径和内容说明。
- 一次建图完成后的地图目录输出。
- 地面、空中悬停、导航中、降落后四组关键 topic 输出。
