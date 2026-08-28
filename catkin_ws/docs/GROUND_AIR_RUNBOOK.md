# 空地两用无人机运行手册

## 安全前提

- 首次运行必须架空车轮、拆桨或进入独立安全区，并保留人工遥控接管。
- 启动文件只启动节点，不会自动解锁、起飞、降落或切换机械模态。
- 起飞高度固定为相对当前高度 `1.0 m`，平台传入的其他高度会被忽略。
- 飞行任务到达最后一个任务点并停留 2 秒后保持悬停，只有收到平台降落指令才降落。

## 环境

```bash
source /opt/ros/noetic/setup.bash
source /home/bitcq/catkin_ws/devel/setup.bash
export LD_LIBRARY_PATH=/home/bitcq/opt/open3d-0.14.1/lib:${LD_LIBRARY_PATH}
```

若 MAVROS 已由 `/home/bitcq/start.sh` 或其他进程启动，所有 launch 均保持 `start_mavros:=false`，避免重复连接飞控。

## 手控建图

```bash
roslaunch car_bringup manual_mapping.launch start_mavros:=false start_video:=true
```

平台的 `slam_start_down`/`slam_stop_down` 用于标记建图会话、保存和上传地图。用于后续重定位的地图目录必须同时包含一个 `.pcd`、一个 `.yaml` 及 YAML 引用的栅格图像。

## 历史地图重定位与自主任务

```bash
roslaunch car_bringup autonomy.launch start_mavros:=false start_video:=true
```

推荐服务顺序：

1. `/ground_air/load_map`：选择或导入历史地图目录。
2. `/ground_air/relocalize`：完全未知位姿时令 `use_initial_guess=false`。
3. `/ground_air/mission/submit`：一次提交整组有序 `PoseStamped[]`。
4. `/ground_air/mission/start`：开始导航；每点自动停留 2 秒。
5. 任务中按需调用 `/ground_air/takeoff` 或 `/ground_air/land`。

## 急停

```bash
rosservice call /ground_air/emergency_stop "active: true"
```

地面模式会同时向地面和空中速度通道持续发送零速度；飞行模式会锁存急停并保持当前位置。排除故障且确认现场安全后才可复位：

```bash
rosservice call /ground_air/emergency_stop "active: false"
```

指控平台对应使用两个独立指令：`emergency_stop_down` 触发并锁存急停，
`emergency_reset_down` 在现场确认安全后解除急停。解除指令不会恢复或重启先前任务，
需要平台重新下发任务控制指令。

## 启动前只读检查

```bash
roslaunch --nodes car_bringup autonomy.launch
rostopic echo -n 1 /ground_air/vehicle_status
rostopic echo -n 1 /ground_air/localization/valid
rostopic echo -n 1 /ground_air/mission/status
```
