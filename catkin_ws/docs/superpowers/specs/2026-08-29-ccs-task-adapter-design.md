# CCS 任务接口与空地机器人任务适配器设计

日期：2026-08-29

## 1. 目标与边界

在 `/home/bitcq/catkin_ws` 中实现 CCS 任务端侧 ROS 接口到现有
`ground_air_mission` 的适配，使指控平台下发的有序任务点能够沿既定的
`ccs-task-control-v2` 链路驱动机器人任务执行并获得进度反馈。

本次只负责 ROS 适配边界，不实现或配置 UDP 14563/14564、设备身份、MQTT、
遥测、建图、重定位、视频或其他设备接入功能。网络侧
`epgeneral_task_control` 由设备接入工作负责。

## 2. 上游固定接口

适配器订阅：

```text
/epgeneral_task_control/execution_command
  epgeneral_task_control/TaskExecutionCommand
```

支持上游既定动作：

```text
SCHEDULE=1
CANCEL=2
STOP=3
PREPARE=4
UNLOAD=5
```

适配器发布：

```text
/epgeneral_task_control/execution_feedback
  epgeneral_task_control/TaskExecutionFeedback
```

指令与反馈中的 `request_id/task_id/subtask_id/device_id/execution_id/revision`
必须原样关联。适配器不修改 `epgeneral_task_control` 的消息、网络协议或存储格式。

## 3. 下游固定接口

适配器仅调用现有受监管服务并订阅状态：

```text
/ground_air/mission/submit
/ground_air/mission/start
/ground_air/mission/cancel
/ground_air/mission/status
/ground_air/vehicle_status
/ground_air/localization/pose
```

适配器不直接调用 MAVROS、不发布底盘运动指令、不解锁飞控，也不执行起飞、
降落或机械模态切换。停止动作仍由 `ground_air_mission` 和现有速度路由执行；
适配器只在 STOP/UNLOAD 的服务调用结果中确认任务已停止。

## 4. 组件与数据流

新增独立功能包 `epaguav_ground_air_task_adapter`，避免修改 CCS 通用接入包或
把平台依赖耦合进 `ground_air_mission`。

编译期需要 `epgeneral_task_control` 提供两种消息定义。远程工作空间中放入
`CCS_dev` 当前提交 `5737fe92a264560f40b91d99ac101ca2d1c6b7d3` 的官方
`EPGeneral_task_control` 包作为未修改的接口依赖，但不配置、不启动其中的 UDP 节点。
以后由设备接入人员维护或替换该包；本适配器只依赖其公开消息契约。

### PREPARE

1. 校验指令身份字段、revision、frame 和 XML 路径。
2. 安全读取 `epgeneral_task_control` 已原子保存的 trajectory XML；允许根目录由 ROS
   参数配置，拒绝符号链接、非普通文件、路径越界、字段缺失、非有限坐标、
   非连续 index 或不满足协议要求的 2–500 个航点。
3. 要求 `frame_id=map`，地图 ID 与指令一致。
4. 将 XYZ 航点转换为 `geometry_msgs/PoseStamped[]`。协议不含 yaw，因此首点朝向
   由当前位置指向首点，后续点由前一点指向当前点；退化的重合点沿用前一航向。
5. 调用 `/ground_air/mission/submit`。成功发布 `ready`，拒绝发布 `failed`。

任务提交仍受现有定位有效和急停检查约束。未定位或急停锁存时 PREPARE 必须失败，
不能绕过安全条件。

### SCHEDULE

1. 只接受与当前已准备任务完全匹配的指令。
2. 先发布 `scheduled`，按 `scheduled_at` 等待。
3. 到时再次核对当前任务代际；随后调用 `/ground_air/mission/start`。
4. 服务成功后发布 `running`；失败发布 `failed`。

定时等待必须可被 CANCEL、STOP、UNLOAD 或新代际打断。时钟明显无效或计划时间
超出允许容差时返回 `CLOCK_UNSYNCED`；不自行修改系统时间。

### CANCEL、STOP 与 UNLOAD

- CANCEL：取消尚未运行或当前任务，调用 `/ground_air/mission/cancel`，反馈 `stopped`。
- STOP：取消当前任务，反馈 `stopped`。
- UNLOAD：取消可能存在的任务，清理适配器内存中的准备/执行状态，反馈 `unloaded`。

重复相同 request ID 返回已缓存结果，不重复调用有副作用的服务；相同 request ID
携带不同内容时拒绝。

CCS 的任务级 `emergency_stop` 最终表现为 UNLOAD。由于 UNLOAD 同时也用于普通删除，
适配器不得把 UNLOAD 映射到锁存的 `/ground_air/emergency_stop`。

### 状态与进度

`/ground_air/mission/status` 映射如下：

```text
IDLE       -> scheduled 或 ready（取决于当前阶段）
RUNNING    -> running
DWELLING   -> running
PAUSED     -> running（message 标明 paused）
SUCCEEDED  -> completed
FAILED     -> failed
CANCELED   -> stopped
WAITING_FOR_LAND -> running
```

进度使用 `current_index/total_goals`；当前位置来自最新、未过期的
`/ground_air/localization/pose`。没有新鲜位置时保留零值并在 message 中说明，不能伪造
定位有效。运行期间至少每秒发布一次匹配当前 execution 的反馈，满足上游 watchdog。

## 5. 并发与安全

- 同时只允许一个已准备任务和一个执行代际。
- 回调、定时器和状态订阅共享锁；任何旧定时器不得启动新任务。
- 所有服务调用设置有限等待时间，异常转换为稳定错误码，不使节点退出。
- 节点退出时尝试取消活动任务，但不触发解锁、起飞、降落或模态切换。
- 平台协议没有 yaw、逐点等待或到点动作；本轮不扩展 CCS schema。
- 继续使用 `ground_air_mission` 的固定两秒停留逻辑。

## 6. 启动方式

功能包提供独立 launch。`ground_air_full.launch` 增加默认关闭的
`start_ccs_task_adapter` 参数；只有同时存在 `epgeneral_task_control` 消息包且用户显式
启用时才启动适配器。默认启动行为保持被动，不改变现有实机流程。

## 7. 测试与验收

采用测试先行：

1. XML 解析：合法轨迹、路径越界、符号链接、错误 frame/map、非法数值、重复 index。
2. 朝向生成：正常路径、首点、重合点和单点任务。
3. 状态机：PREPARE、SCHEDULE、定时启动、CANCEL、STOP、UNLOAD、重复 request ID、
   旧定时器失效。
4. 状态映射：成功、失败、取消、停留和等待降落。
5. ROS 契约：话题类型、服务名称、默认关闭的 launch 参数和依赖声明。
6. 在远程执行包级单元测试、Python 编译检查、`catkin_make` 与 launch 展开检查。

测试期间不运行控制栈，不调用真实运动服务。实机联调由用户明确启动后再进行。
