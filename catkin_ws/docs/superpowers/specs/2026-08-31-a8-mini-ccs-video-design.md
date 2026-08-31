# A8 Mini 与 CCS SRT 视频接入设计

日期：2026-08-31

## 1. 目标与边界

在远程 `/home/bitcq/catkin_ws` 中补齐 SIYI A8 Mini 云台相机的视频链路，
并将摄像头和 CCS 官方 SRT 视频节点接入 `car_bringup/launch/base_system.launch`。

本次交付保证机器人端具备以下链路：

```text
A8 Mini RTSP
  -> ROS sensor_msgs/Image
  -> H.264 baseline / MPEG-TS
  -> SRT Listener UDP 9000
  -> CCS_dev FFmpeg SRT Caller
```

本次只实现实时图像采集和 CCS 视频传输，不引入云台转动、变焦、拍照、录像、
目标识别、仪表识别或灯光识别功能，不修改建图、重定位、任务、底盘、飞控和 TF
链路，也不自动解锁或切换模态。

## 2. 已确认的设备与 CCS 契约

- A8 Mini 地址：`192.168.144.25`，机器人 `eth0` 为 `192.168.144.50/24`，实测可达。
- A8 Mini 主码流：`rtsp://192.168.144.25:8554/main.264`。
- ROS 图像话题：`/a8_cam/image_raw`，消息类型 `sensor_msgs/Image`。
- 机器人无线地址：`192.168.50.130`。
- CCS 设备身份：`AGV_001`。
- CCS 视频协议：机器人作为 SRT Listener，监听 UDP 9000；CCS_dev 作为 Caller
  按需连接机器人地址，不需要机器人配置地面站地址。
- 编码与封装：H.264 baseline、MPEG-TS、30 fps、640×480、2000 kbit/s、
  SRT latency 120 ms。

CCS_dev 仓库中的示例设备记录仍可能使用旧地址。实际运行 CCS 时，设备
`AGV_001` 的地址必须设置为 `192.168.50.130`，SRT 端口为 9000。

## 3. 方案选择

采用轻量 A8 Mini ROS 图像桥接节点，并复用 CCS 官方
`epgeneral_video_srt v0.1.0`。

不直接复用回收站完整 `photo_function`。该包虽然包含 A8 Mini 控制能力，但强制
编译 CUDA、TensorRT、仪表识别、灯光识别、USB 相机和双光相机模块；这些依赖与
本次实时视频目标无关，会扩大编译和运行风险。

不采用 RTSP 直接转 SRT。直接转发虽然更短，但不会形成 ROS 图像话题，并绕开
CCS 官方端侧视频包，不利于后续图像算法复用和统一维护。

## 4. 组件设计

### 4.1 `a8_mini_camera`

新增独立 ROS1 包，只承担 RTSP 到 ROS 图像的桥接：

- 使用 OpenCV/FFmpeg 打开可配置 RTSP URL。
- 发布可配置的绝对图像话题，默认 `/a8_cam/image_raw`。
- 默认 frame 为 `a8_cam`，不发布未经标定的相机外参或 CameraInfo。
- 以最新帧优先，避免网络抖动造成不断增长的旧帧积压。
- 断流后停止发布旧图像，记录节流告警并自动重连。
- 参数非法时明确退出；相机暂时离线不导致基础系统或其他节点退出。

### 4.2 `epgeneral_video_srt`

把 CCS_dev 当前正式 `epgeneral_video_srt v0.1.0` 纳入当前工作空间，不修改其
协议实现。为空地机器人增加配置，输入 `/a8_cam/image_raw`，在
`0.0.0.0:9000/udp` 建立 SRT Listener。

`EPGeneral_device_config/config/device.yaml` 统一为：

```yaml
schema_version: 1
device:
  id: "AGV_001"
  ip: "192.168.50.130"
```

### 4.3 `base_system.launch`

在现有基础层增加带注释的可配置参数：

```text
start_a8_camera=true
start_video_srt=true
a8_camera_ip=192.168.144.25
a8_image_topic=/a8_cam/image_raw
srt_port=9000
```

默认同时启动摄像头桥接和 SRT 节点；两个开关允许维护时独立关闭。摄像头或视频
节点不是 REQUIRED 进程，其故障不得触发 MAVROS、Livox 或整个 launch 退出。

## 5. 数据流与启动顺序

1. `base_system.launch` 启动 A8 Mini 图像桥接节点。
2. 图像桥接节点连接 RTSP，成功取帧后发布 `/a8_cam/image_raw`。
3. `epgeneral_video_srt` 可同时启动并等待图像；收到首帧后编码并送入 SRT 管线。
4. SRT 节点在机器人 UDP 9000 等待 Caller。
5. 用户在 CCS_dev 设备详情页打开视频，地面站 FFmpeg 连接
   `srt://192.168.50.130:9000?mode=caller` 并显示视频。

## 6. 故障处理

- A8 Mini 不可达：桥接节点持续低频重连，不发布空白或历史帧。
- RTSP 中断：图像话题停止更新，SRT 节点的帧看门狗报告停止，不影响车辆控制。
- UDP 9000 被占用或缺少 GStreamer 插件：SRT 节点明确失败，基础系统继续运行。
- CCS 未连接：SRT Listener 正常等待，不视为机器人端故障。
- CCS 设备 IP/ID 不匹配：机器人端保持监听，由部署检查提示修正 CCS 设备记录。

## 7. 测试与验收

实现遵循测试先行：先增加配置/launch 契约测试并确认其因功能缺失而失败，再完成
最小实现。

验证顺序：

1. XML/参数测试确认 `base_system.launch` 的开关、话题、配置和非 REQUIRED 约束。
2. 节点单元测试确认参数校验、断流不发布旧帧和重连状态转换。
3. 完整 `catkin_make` 成功。
4. 使用 `start_mavros:=false start_livox:=false` 隔离启动视频链，不触碰车辆控制。
5. `rostopic hz /a8_cam/image_raw` 持续有新帧。
6. `ss -lunp` 显示 UDP 9000 Listener，日志出现首帧进入编码器。
7. 本机 SRT Caller 解码验证 H.264/MPEG-TS 画面。
8. CCS_dev 将 `AGV_001` 配置为 `192.168.50.130:9000`，在设备详情页打开视频并
   验证持续画面和断开后的自动重试。

实机验证期间不解锁、不启动导航、不发送速度、起飞、降落或模态切换指令。
