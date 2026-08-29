# epaguav_ground_air_task_adapter

将 CCS `epgeneral_task_control` 的强类型任务指令转换为现有空地机器人任务服务。
本包不监听 UDP、不直接调用 MAVROS，也不执行解锁、起飞、降落或空地模态切换。

```text
/epgeneral_task_control/execution_command
  -> /ground_air/mission/submit|start|cancel
  -> /epgeneral_task_control/execution_feedback
```

默认任务 XML 根目录为 `/home/bitcq/ccs_edge_ws/mission`。任务准备要求机器人已经
重定位且急停已解除；这些条件由 `ground_air_mission` 继续强制执行。

独立启动：

```bash
roslaunch epaguav_ground_air_task_adapter task_adapter.launch
```

总启动文件中的适配器参数默认关闭，只有完成端侧任务接入部署后才显式开启。
