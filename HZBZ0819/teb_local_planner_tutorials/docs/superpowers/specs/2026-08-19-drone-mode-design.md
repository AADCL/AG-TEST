# 无人机模态 ROS 启动与控制桥设计

## 目标

为 `teb_local_planner_tutorials` 增加可由 `bz_navigation.launch` 启动的无人机模态节点。节点复用现有 `PX4Drone` 控制类，将 TEB 输出的二维机体速度转换为 MAVROS 速度指令，并通过 ROS 服务显式执行起飞和降落。

## 启动行为

`bz_navigation.launch` 新增布尔参数 `enable_drone_mode`，默认值为 `false`。参数为 `true` 时启动 `drone_mode_node.py`；默认关闭可防止地面导航启动时意外切换飞行模态。

无人机节点启动后等待 MAVROS 服务和飞控连接，然后调用 `switch_mode("drone")`。启动过程不解锁飞控，也不自动起飞。模式切换失败时，节点记录错误并退出，避免在未知模态下继续接收导航命令。

启动文件向节点传入以下私有参数：

- `cmd_vel_topic`：默认 `/cmd_vel`
- `takeoff_height`：默认 `1.0 m`
- `cmd_vel_timeout`：默认 `0.5 s`
- `max_horizontal_speed`：默认 `1.0 m/s`
- `max_yaw_rate`：默认 `1.0 rad/s`
- `altitude_kp`：默认 `1.0`
- `max_vertical_speed`：默认 `0.5 m/s`
- `control_rate`：默认 `20 Hz`

## ROS 接口

节点名称为 `drone_mode`，提供两个 `std_srvs/Trigger` 服务：

- `/drone_mode/takeoff`：起飞到 `takeoff_height`
- `/drone_mode/land`：停止导航速度并执行降落

节点订阅 `cmd_vel_topic` 指定的 `geometry_msgs/Twist`。只有起飞成功且节点处于空中控制状态时，速度命令才会生效。起飞前、降落中以及降落后收到的速度命令均被忽略。

服务回调返回明确的成功状态和结果消息。使用互斥锁防止起飞和降落服务同时执行。

## 速度与高度控制

TEB 的速度按机体坐标解释：

- `linear.x`：前后速度
- `linear.y`：左右速度
- `angular.z`：偏航角速度
- `linear.z`：忽略

节点读取 MAVROS 当前姿态中的偏航角，将机体系水平速度转换为地图坐标系：

```text
vx_world = cos(yaw) * vx_body - sin(yaw) * vy_body
vy_world = sin(yaw) * vx_body + cos(yaw) * vy_body
```

水平速度向量的模长限制为 `max_horizontal_speed`，偏航角速度限制为 `max_yaw_rate`。

起飞成功后记录目标高度。垂直速度采用比例控制：

```text
vz = clamp(altitude_kp * (target_altitude - current_altitude),
           -max_vertical_speed,
           max_vertical_speed)
```

节点以 `control_rate` 指定的频率持续向 `PX4Drone` 提交水平速度、垂直速度和偏航角速度。

## 超时与安全行为

如果超过 `cmd_vel_timeout` 未收到新的 `/cmd_vel`，节点将水平速度和偏航角速度置零，但继续执行高度保持。

调用降落服务时，节点立即停止导航速度输出，然后调用 `PX4Drone.land()`。降落成功后回到待机状态。

节点关闭时复用 `PX4Drone` 已有的关闭钩子：车辆模态停止执行器，飞行模态且仍解锁时尝试安全降落。

## 代码边界

- `drone_mode_node.py`：ROS 订阅、服务、状态机、限幅、坐标转换和命令超时。
- `px4_drone.py`：继续负责 MAVROS 服务、飞控状态以及底层 setpoint 发布；扩展连续速度命令以支持偏航角速度。
- `bz_navigation.launch`：只负责按参数条件启动无人机节点并传递配置。
- `package.xml`：声明 `rospy`、`geometry_msgs`、`std_srvs`、`sensor_msgs` 和 `mavros_msgs` 运行依赖。
- `CMakeLists.txt`：使用 `catkin_install_python` 安装可执行节点脚本，并安装作为同目录模块导入的 `px4_drone.py`。

纯数学逻辑应保持为无 ROS 副作用的函数，以便在没有 ROS master 和飞控硬件时执行单元测试。

## 验证标准

自动化测试覆盖：

1. 机体系到地图系的速度转换。
2. 水平速度、偏航角速度和垂直速度限幅。
3. 起飞前忽略 `/cmd_vel`。
4. 起飞成功后接受 `/cmd_vel`。
5. 命令超时后水平速度和偏航速度归零，同时保留高度修正。
6. 起飞和降落服务的成功及失败返回。
7. `bz_navigation.launch` 包含条件启动节点及全部参数。

在具备 ROS1、MAVROS 和 PX4 的环境中，还需验证：

1. `roslaunch ... bz_navigation.launch enable_drone_mode:=true` 只切换模态，不自动解锁或起飞。
2. 调用 `/drone_mode/takeoff` 后起飞到配置高度。
3. TEB `/cmd_vel` 可控制机体前后、横向和偏航运动。
4. `/cmd_vel` 中断后无人机停止水平运动并保持高度。
5. 调用 `/drone_mode/land` 后安全降落。
