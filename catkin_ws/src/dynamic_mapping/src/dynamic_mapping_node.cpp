#include <ros/ros.h>
#include <iostream>
#include <sensor_msgs/PointCloud2.h>
#include <dynamic_mapping.h>


int main(int argc, char** argv)
{
    ros::init(argc, argv, "dynamic_mapping");
    ros::NodeHandle nh,private_nh("~");

    DynamicMap::dynamic_map map(nh,private_nh);
    
    ros::spin();
    return 0;
}