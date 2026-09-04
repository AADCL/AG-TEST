# AG-TEST
用于空地无人机的开发代码管理

2026-0904
在 `ground_air_mapping` 中移植 UGV 建图端半径离群点检测与三维贝叶斯运动滤波。
新增有限值及距离裁剪、0.05 m 单帧体素降采样、0.15 m 半径离群检测，以及基于 0.20 m 粗体素的静态确认和自由空间射线清除。
运动滤波只改变最终保存的 `cloud_map.pcd`；实时导航仍使用 `/cloud_registered_body` 感知动态障碍，FAST-LIO、重定位、TF、PGM/YAML 和既有建图服务接口保持不变。
新增 `/ground_air/mapping/static_cloud` 诊断话题，`/ground_air/mapping/dynamic_points` 默认关闭，并补充参数 YAML、C++ 单元测试、包契约测试和中文修改说明。
远程 `/home/bitcq/catkin_ws` 已完成单线程完整编译，`ground_air_mapping` 包级测试共 7 项、0 错误、0 失败。

2026-0831
完成 A8 Mini 云台相机与 CCS_dev 视频链路的机器人侧集成。
新增 a8_mini_camera 功能包，通过 RTSP 读取相机主码流并发布 /a8_cam/image_raw。
集成 EPGeneral_video_srt，将 ROS 图像编码为 H.264，并通过 SRT 监听端口 9000 提供给指控平台。
更新 base_system.launch，默认启动摄像头和视频推流，同时保留独立关闭参数，视频故障不会终止基础系统。
设备标识配置为 AGV_001，机器人地址配置为 192.168.50.130；完成约 25 Hz 图像发布和 SRT 调用端解析验证。
远程主机已在 ~/.bashrc 中自动加载 ROS Noetic 与 /home/bitcq/catkin_ws/devel/setup.bash，新终端无需手动 source。

2026-0829
完成 CCS 指控平台任务接口与空地机器人任务执行器的 ROS 适配。
新增 epaguav_ground_air_task_adapter，接收任务准备、定时执行、停止、取消和卸载指令，并向平台反馈任务状态、进度和当前位置。
新增任务 XML 安全校验、任务点航向自动生成、重复请求幂等处理和定时启动保护。
接入 epgeneral_task_control 的强类型任务消息，并在 car_bringup 中增加默认关闭的 start_ccs_task_adapter 启动开关。
适配层只调用 ground_air_mission 服务，不接管 UDP、MAVROS、解锁、起飞、降落、急停或空地模态切换。
完成工作空间编译、适配器测试、原任务执行器回归测试和 launch 展开检查。

2026-0828
完成了空地无人机地面模态的全流程测试
更改了启动方式和tf_tree

2026-0819
完成了无人机模态的开发。
新增 drone_mode_node.py，提供起飞、降落服务，处理坐标转换、限速、高度保持和指令超时。
扩展 px4_drone.py，支持连续速度目标及偏航角速度。
增加状态锁，避免速度发布与起降服务并发冲突。
补充 ROS 依赖、Python 安装规则和自动化测试。
