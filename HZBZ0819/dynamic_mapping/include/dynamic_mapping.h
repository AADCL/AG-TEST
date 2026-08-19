#ifndef __Dynamic_Mapping_H__
#define __Dynamic_Mapping_H__
#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>
#include <nav_msgs/OccupancyGrid.h>
#include <map_msgs/OccupancyGridUpdate.h>
#include <pcl/point_types.h>
#include <pcl/common/transforms.h>
#include <pcl/conversions.h>
#include <pcl_ros/point_cloud.h>
#include <pcl_ros/transforms.h>
#include <opencv2/opencv.hpp>
#include <point.h>
#include <gridlinetraversal.h>

#include <sensor_msgs/CompressedImage.h>
#include <opencv2/opencv.hpp>
#include <cv_bridge/cv_bridge.h>

namespace DynamicMap
{
    class dynamic_map
    {
    private:
        ros::Publisher dynamicMapPub, image_pub;
        ros::Subscriber registerCloudSub;
        // nav_msgs::OccupancyGrid map;
        tf::TransformListener *tfListener;

        // Param
    private:
        std::string dynamicMapTopic;
        std::string registerdCloud;
        double mapResolution;
        double mapMinHeight, mapMaxHeight;
        double lidarVisionSize, lidarBlindSize;
        std::string mapFrameId, lidarFrameId;
        // tf::Quaternion initOritation;
        // tf::Vector3 initPose;

        cv::Mat dynamicMap;
        int mapWidth, mapHeight;
        IntPoint mapCenter;

        std::vector<pcl::PointXYZ> affectCloud;
        std::vector<pcl::PointXYZ> affectScan;

        int zonenum;
        std::vector<std::vector<pcl::PointXYZ>> ScanInZone;

    public:
        dynamic_map(ros::NodeHandle &nh, ros::NodeHandle &private_nh);
        ~dynamic_map(){}
        void initMap();
        void getCloud(const sensor_msgs::PointCloud2ConstPtr cloud);
        void updateMap(pcl::PointCloud<pcl::PointXYZ>::Ptr registCloud, ros::Time &stamp);
        IntPoint transToMap(Point pose);
        Point transFromMap(IntPoint pose);
        void mapExpand(IntPoint size);
        void mapExpand(int top, int bottom, int left, int right);
        void setMapPiexlFree(IntPoint mapPixel);
        void setMapPiexlOccupid(IntPoint mapPixel);
        void publishMap(ros::Time &stamp);
        void trans2Scan(Point lidarPose);
        void occupancyGridToImage(const nav_msgs::OccupancyGrid msg);
    };
}

#endif