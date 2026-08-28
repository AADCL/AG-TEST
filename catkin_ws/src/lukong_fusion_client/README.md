# 路空无人机 ROS1 地图融合客户端

该包用于把路空 SpiritWing 无人机的 ROS1 点云和位姿数据接入地图融合服务器。

当前客户端不依赖 ROS2，也不依赖 `swing_msgs`。它直接订阅路空真机已验证的 ROS1 topic，把关键帧点云保存为 PCD，通过本机 HTTP 文件服务暴露下载地址，再按 `fusion_server` 当前实际接口发送 JSON。

## 默认路空链路

根据 `bingzhi-wurenji/spiritwing_web` 的现场调试记录，路空无人机当前真机默认使用：

- 位姿：`/Odometry`，类型 `nav_msgs/Odometry`。
- 位姿兜底：`/mavros/local_position/odom`，类型 `nav_msgs/Odometry`。
- 点云：默认使用 `/cloud_registered_body`，类型 `sensor_msgs/PointCloud2`。
- 点云 PCD 字段：`x y z intensity`。如果 ROS 点云没有 `intensity` 字段，客户端会补 `0.0`。

注意：`/cloud_registered` 已用于路空 Web 模块的实时点云和地图上传，它更像注册后的世界系点云。融合服务端的 `KeyFrame.msg` 注释要求点云是 `body frame (undistorted)`，并会在服务端按关键帧 pose 变换到世界系，因此融合客户端默认优先用 `/cloud_registered_body`。

## 数据流

```text
路空 ROS1
  /Odometry
  /cloud_registered_body
      |
      v
lukong_fusion_client_node.py
  1. 根据距离/yaw/时间阈值生成关键帧
  2. 保存 PointCloud2 为 /tmp/lukong_fusion_client/pcd/*.pcd
  3. 启动 Flask: http://<robot_ip>:5000/pcd/<file>.pcd
  4. POST http://<fusion_server>:8080/keyframe_data
      |
      v
fusion_server
  http_data_receiver.py 下载 PCD -> 发布 ROS2 /keyframe_data
  multi_robot_map_fusion_node 做 ScanContext + NanoGICP + GTSAM 优化
```

## 目录

```text
lukong_fusion_client/
├── CMakeLists.txt
├── package.xml
├── config/lukong_fusion_client.yaml
├── launch/lukong_fusion_client.launch
├── scripts/lukong_fusion_client_node.py
└── start_lukong_fusion_client.sh
```

## 部署

把 `lukong_fusion_client` 放到路空无人机 ROS1 catkin 工作空间的 `src` 下：

```bash
cd ~/lukong_fusion_ws/src
cp -r /path/to/lukong_fusion_client .

cd ~/lukong_fusion_ws
catkin_make
source devel/setup.bash
```

安装 Python 依赖：

```bash
pip3 install flask requests numpy
```

## 配置

修改：

```text
config/lukong_fusion_client.yaml
```

关键参数：

```yaml
lukong_fusion_client:
  fusion_server: "http://192.168.50.165:8080"
  robot_ip: "192.168.50.11"
  http_port: 5000

  robot_id: "SPIRITWING_LUKONG_SN"
  area_id: "123"

  odom_topic: "/Odometry"
  fallback_odom_topic: "/mavros/local_position/odom"
pointcloud_topic: "/cloud_registered_body"
```

`robot_ip` 必须是融合服务器能访问到的无人机 IP，因为服务器会通过：

```text
http://<robot_ip>:5000/pcd/<file>.pcd
```

反向下载点云文件。

## 启动

方式 1：直接 roslaunch：

```bash
cd ~/lukong_fusion_ws
source devel/setup.bash
roslaunch lukong_fusion_client lukong_fusion_client.launch
```

方式 2：使用启动脚本：

```bash
cd ~/lukong_fusion_ws
source devel/setup.bash
bash "$(rospack find lukong_fusion_client)/start_lukong_fusion_client.sh"
```

如果脚本没有执行权限：

```bash
chmod +x src/lukong_fusion_client/start_lukong_fusion_client.sh
chmod +x src/lukong_fusion_client/scripts/lukong_fusion_client_node.py
```

## 关键帧策略

默认行为尽量贴近 ROS2 原客户端：客户端启动后按关键帧策略发送数据，不直接接收平台命令：

```yaml
send_policy: "always"
```

ROS2 原客户端只是订阅本机 ROS2 `/keyframe_data`，把已有 KeyFrame 转 HTTP 发给融合服务器；ROS1 版没有现成 `KeyFrame` topic，所以用路空 odom + body 点云生成同等 HTTP payload。

如果现场需要跟随 `spiritwing_web` 的建图命令，也可以改为订阅占位命令 topic：

```yaml
send_policy: "slam_command"
slam_command_topic: "/spiritwing/command_json_placeholder"
slam_start_delay_s: 8.0
update_area_id_from_slam_command: true
```

关键帧不是每帧点云都发送，而是按阈值生成：

```yaml
keyframe_check_period_s: 1.0
keyframe_min_interval_s: 2.0
keyframe_distance_m: 0.8
keyframe_yaw_deg: 12.0
max_points_per_keyframe: 8000
```

含义：

- 每 1 秒检查一次。
- 距离上次发送至少 2 秒。
- 移动超过 0.8 米，或 yaw 变化超过 12 度，才发送新的关键帧。
- 每个关键帧最多写入 8000 个点，避免 HTTP 和融合端压力过大。
- `update_area_id_from_slam_command: true` 时，会使用平台建图命令里的 `area_id` 覆盖本地配置。

## HTTP 接口

当前 `fusion_server` 实际代码路由是：

```text
POST /keyframe_data
POST /keyframe_poses
POST /start_fusion_node
POST /save_fused_map
```

本 ROS1 客户端当前只发送关键帧：

```text
POST /keyframe_data
```

请求核心字段：

```json
{
  "type": "keyframe",
  "forward": true,
  "robot_id": "SPIRITWING_LUKONG_SN",
  "area_id": "123",
  "keyframe_id": 1,
  "header": {
    "stamp": {"sec": 0, "nanosec": 0},
    "frame_id": "map"
  },
  "pose": {
    "position": {"x": 0.0, "y": 0.0, "z": 0.0},
    "orientation": {"x": 0.0, "y": 0.0, "z": 0.0, "w": 1.0}
  },
  "url": "http://192.168.50.11:5000/pcd/000001_xxxxxxxx.pcd",
  "timestamp": {"sec": 0, "nanosec": 0}
}
```

## 联调检查

在路空无人机上先确认：

```bash
rostopic type /Odometry
rostopic type /cloud_registered
rostopic echo -n 1 /Odometry
rostopic echo -n 1 /cloud_registered
```

在融合服务器上确认 HTTP 服务：

```bash
curl http://192.168.50.165:8080/health
```

在融合服务器上确认能访问无人机 PCD HTTP 服务：

```bash
curl http://192.168.50.11:5000/pcd/
```

注意 `/pcd/` 目录本身可能返回 404，这是正常的；真正验证时应使用客户端日志里打印出的完整 PCD URL。

## 后续可扩展

- 如果需要向融合服务器发送优化后的关键帧位姿，可补充 `POST /keyframe_poses`。
- 如果需要由指控平台触发开始/保存融合地图，可调用服务器现有 `/start_fusion_node` 和 `/save_fused_map`。
- 如果路空现场 topic 变化，只改 `config/lukong_fusion_client.yaml`，无需改代码。
