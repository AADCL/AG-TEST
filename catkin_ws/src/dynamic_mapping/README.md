# Dynamic Mapping

## depends

- OpenCV
- PCL
  
## Usage

订阅SLAM程序发布的`/cloud_registered`点云数据，并订阅`map`到`lidar`坐标系的tf。发布可根据环境动态变化的全局地图`/map`。

## params

- dynamic_map_topic ： 动态全局地图的topic名称
- register_cloud ： 订阅SLAM的`map`系下的点云数据
- map_resolution ： 地图的分辨率，单位`m`
- map_min_height ： 地图考虑的最低高度
- map_max_height ： 地图考虑的最高高度
- map_frame_id ： 地图的坐标系名称
- lidar_frame_id ： 雷达坐标系名称
- lidar_vision_size ： 雷达感知范围
- lidar_blind_size ： 雷达屏蔽范围