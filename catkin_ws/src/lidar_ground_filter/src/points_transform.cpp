#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>
#include <pcl/point_types.h>
#include <pcl/common/transforms.h>
#include <pcl/conversions.h>
#include <pcl_ros/point_cloud.h>
#include <pcl_ros/transforms.h>

tf::TransformListener *tfListener;
ros::Publisher lidar_trans_pub;
ros::Publisher lidar_noground_pub;
std::string mapFrameId, lidarFrameId;

void lidarTrans2world(const sensor_msgs::PointCloud2ConstPtr msg)
{
    pcl::PointCloud<pcl::PointXYZI>::Ptr cloud_origin(new pcl::PointCloud<pcl::PointXYZI>());
    pcl::fromROSMsg(*msg, *cloud_origin);
    ros::Time stamp = msg->header.stamp;
    
    sensor_msgs::PointCloud2 output_cloud;
    pcl::PointCloud<pcl::PointXYZI>::Ptr cloud_out(new pcl::PointCloud<pcl::PointXYZI>());
    tf::StampedTransform transform;
    try
    {
        tfListener->waitForTransform(mapFrameId, lidarFrameId, msg->header.stamp, ros::Duration(0.1));
        tfListener->lookupTransform(mapFrameId, lidarFrameId, msg->header.stamp, transform);
    }
    catch (tf::TransformException ex)
    {
        ROS_WARN("%s", ex.what());
        return;
    }
    Eigen::Matrix4f eigen_tranform;
    pcl_ros::transformAsMatrix(transform, eigen_tranform);
    // pcl_ros::transformPointCloud(eigen_tranform, *msg, output_cloud);
    pcl::transformPointCloud(*cloud_origin, *cloud_out, eigen_tranform);
    pcl::toROSMsg(*cloud_out, output_cloud);
    output_cloud.header = msg->header;
    output_cloud.header.frame_id = mapFrameId;
    lidar_noground_pub.publish(output_cloud);

}

int main(int argc, char **argv)
{
    ros::init(argc, argv, "points_transform");
    ros::NodeHandle nh, private_nh("~");

    std::string input_lidar_topic, output_lidar_topic;
    std::string tf_prefix;

    nh.param<std::string>("tf_prefix", tf_prefix, "");
    private_nh.param<std::string>("map_frame", mapFrameId, "world");
    private_nh.param<std::string>("lidar_frame", lidarFrameId, "rslidar");
    if(tf_prefix != "")
    {
        mapFrameId = tf_prefix + "/" + mapFrameId;
        lidarFrameId = tf_prefix + "/" + lidarFrameId;
    }
    private_nh.param<std::string>("lidar_input", input_lidar_topic, "cloud_registered");
    private_nh.param<std::string>("lidar_output", output_lidar_topic, "withoutGround_world");

    tfListener = new tf::TransformListener();
    ros::Subscriber outputCloudSub = nh.subscribe("filtered_points_no_ground", 1, &lidarTrans2world, ros::TransportHints().tcpNoDelay());
    lidar_noground_pub = nh.advertise<sensor_msgs::PointCloud2>(output_lidar_topic, 1);

    ros::spin();
    return 0;
}