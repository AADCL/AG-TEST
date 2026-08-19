#include <dynamic_mapping.h>
#include <iostream>
#include <cmath>
#include <omp.h>

namespace DynamicMap
{
    bool compare_y(pcl::PointXYZ a, pcl::PointXYZ b)
    {
        return a.y < b.y;
    }

    bool compare_pointy(Point a, Point b)
    {
        return a.y < b.y;
    }

    dynamic_map::dynamic_map(ros::NodeHandle &nh, ros::NodeHandle &private_nh)
    {
        std::string tf_prefix;
        nh.param<std::string>("tf_prefix", tf_prefix, "");
        private_nh.param<std::string>("dynamic_map_topic", dynamicMapTopic, "dynamic_map");
        private_nh.param<std::string>("register_cloud", registerdCloud, "register_cloud");
        private_nh.param<double>("map_resolution", mapResolution, 0.05);
        private_nh.param<double>("map_min_height", mapMinHeight, 0.0);
        private_nh.param<double>("map_max_height", mapMaxHeight, 2.0);
        private_nh.param<std::string>("map_frame_id", mapFrameId, "map");
        private_nh.param<std::string>("lidar_frame_id", lidarFrameId, "lidar");
        if(tf_prefix != "")
        {
            mapFrameId = tf_prefix + "/" + mapFrameId;
            lidarFrameId = tf_prefix + "/" + lidarFrameId;
        }
        private_nh.param<double>("lidar_vision_size", lidarVisionSize, 20.0);
        private_nh.param<double>("lidar_blind_size", lidarBlindSize, 0.8);
        private_nh.param<int>("lidar_zone_num", zonenum, 3600);
        ScanInZone.resize(zonenum);
        tfListener = new tf::TransformListener();
        registerCloudSub = nh.subscribe(registerdCloud, 10, &dynamic_map::getCloud, this, ros::TransportHints().tcpNoDelay());
        dynamicMapPub = nh.advertise<nav_msgs::OccupancyGrid>(dynamicMapTopic, 1);
        image_pub = nh.advertise<sensor_msgs::CompressedImage>("/map_image/compressed", 10);
        initMap();
    }

    void dynamic_map::initMap()
    {
        mapWidth = 100;
        mapHeight = 100;
        mapCenter.x = 50;
        mapCenter.y = 50;
        dynamicMap = cv::Mat(mapWidth, mapHeight, CV_8SC1, cv::Scalar(-1));
    }

    void dynamic_map::getCloud(const sensor_msgs::PointCloud2ConstPtr cloud)
    {
        pcl::PointCloud<pcl::PointXYZ>::Ptr registerCloud(new pcl::PointCloud<pcl::PointXYZ>());
        pcl::fromROSMsg(*cloud, *registerCloud);
        ros::Time stamp = cloud->header.stamp;
        double start_time = omp_get_wtime();
        updateMap(registerCloud, stamp);
        double end_time = omp_get_wtime();
        ROS_INFO_STREAM("Update Map COST: " << end_time - start_time << " seconds.");
    }

    void dynamic_map::updateMap(pcl::PointCloud<pcl::PointXYZ>::Ptr registCloud, ros::Time &stamp)
    {
        tf::StampedTransform transform;
        try
        {
            tfListener->waitForTransform(mapFrameId, lidarFrameId, stamp, ros::Duration(0.5));
            tfListener->lookupTransform(mapFrameId, lidarFrameId, stamp, transform);
        }
        catch (tf::TransformException ex)
        {
            ROS_WARN("%s", ex.what());
            return;
        }
        tf::Vector3 lidar_origin = transform.getOrigin();
        tf::Quaternion lidar_quat = transform.getRotation();

        // map下点坐标、雷达坐标已知，求经过的栅格(Bresenham算法)
        IntPoint lidar_pose;
        
        std::vector<GridLineTraversalLine> lineList;

        affectCloud.clear();
        // 按需扩展地图
        std::vector<int> outsidePoints_x, outsidePoints_y;
        outsidePoints_x.clear();
        outsidePoints_y.clear();
        #pragma omp parallel num_threads(4)
        {
            #pragma omp for
            for (auto pt : registCloud->points)
            {
                double len = euclidianDist(Point(pt.x, pt.y), Point(lidar_origin.x(), lidar_origin.y()));
                // 判断点云高度是否符合 或者点云在可视范围外
                if (pt.z - lidar_origin.z() < mapMinHeight || pt.z - lidar_origin.z() > mapMaxHeight || len > lidarVisionSize || len < lidarBlindSize)
                {
                    continue;
                }
                IntPoint temp_pt;
                temp_pt = transToMap(Point(pt.x, pt.y));
                #pragma omp critical
                {
                    affectCloud.push_back(pt);
                }
                // 判断点云是否在地图内
                if (!temp_pt.inMap(mapHeight, mapWidth))
                {
                    #pragma omp critical
                    {
                        outsidePoints_x.push_back(temp_pt.x);
                        outsidePoints_y.push_back(temp_pt.y);
                    }
                }
            }
        }

        // std::cout << affectCloud.size() << std::endl;
        if (outsidePoints_x.size() > 0 && outsidePoints_y.size() > 0)
        {
            // std::cout << outsidePoints_x.size() << " " << outsidePoints_y.size() << std::endl;
            if (outsidePoints_x.size() != 1)
            {
                int top, bottom, left, right;
                top = *min_element(outsidePoints_y.begin(), outsidePoints_y.end());
                bottom = *max_element(outsidePoints_y.begin(), outsidePoints_y.end());
                left = *min_element(outsidePoints_x.begin(), outsidePoints_x.end());
                right = *max_element(outsidePoints_x.begin(), outsidePoints_x.end());

                top = 0 - top;
                top = top >= -10 ? top + 20 : 0;
                bottom = bottom - mapHeight;
                bottom = bottom >= -10 ? bottom + 20 : 0;
                left = 0 - left;
                left = left >= -10 ? left + 20 : 0;
                right = right - mapWidth;
                right = right >= -10 ? right + 20 : 0;
                mapExpand(top, bottom, left, right);
                // std::cout << "********************************" << std::endl;
                // std::cout << "top: " << top << " bottom: " << bottom << " left: " << left << " right: " << right << std::endl;
                // std::cout << "mapWidth: " << mapWidth << " mapHeight: " << mapHeight << std::endl;
                // for (int i = 0; i < outsidePoints_x.size(); i++)
                // {
                //     std::cout << outsidePoints_x[i] << " " << outsidePoints_y[i] << std::endl;
                // }
            }
            if (outsidePoints_x.size() == 1)
            {
                int top = 0, bottom = 0, left = 0, right = 0;
                if (outsidePoints_x[0] >= mapWidth)
                {
                    right = outsidePoints_x[0] - mapWidth + 10;
                }
                else if (outsidePoints_x[0] < 0)
                {
                    left = -outsidePoints_x[0] + 10;
                }
                if (outsidePoints_y[0] >= mapHeight)
                {
                    bottom = outsidePoints_y[0] - mapHeight + 10;
                }
                else if (outsidePoints_y[0] < 0)
                {
                    top = -outsidePoints_y[0] + 10;
                }
                mapExpand(top, bottom, left, right);
                // std::cout << "----------------------" << std::endl;
                // std::cout << "top: " << top << " bottom: " << bottom << " left: " << left << " right: " << right << std::endl;
                // std::cout << "mapWidth: " << mapWidth << " mapHeight: " << mapHeight << std::endl;
                // for (int i = 0; i < outsidePoints_x.size(); i++)
                // {
                //     std::cout << outsidePoints_x[i] << " " << outsidePoints_y[i] << std::endl;
                // }
            }
        }

        // TODO: 判断车是否到地图外，将要出地图就扩展地图
        lidar_pose = transToMap(Point(lidar_origin.x(), lidar_origin.y()));
        if(!lidar_pose.inMap(mapHeight, mapWidth))
        {
            int top = 0, bottom = 0, left = 0, right = 0;
            if(lidar_pose.x >= mapWidth )
            {
                right = lidar_pose.x - mapWidth + 10;
            }
            else if(lidar_pose.x < 0)
            {
                left = -lidar_pose.x + 10;
            }
            if(lidar_pose.y >= mapHeight)
            {
                bottom = lidar_pose.y - mapHeight + 10;
            }
            else if(lidar_pose.y < 0)
            {
                top = -lidar_pose.y + 10;
            }
            top = std::max(0, top);
            bottom = std::max(0, bottom);
            left = std::max(0, left);
            right = std::max(0, right);
            mapExpand(top, bottom, left, right);
            lidar_pose = transToMap(Point(lidar_origin.x(), lidar_origin.y()));
        }

        // 将三维点云转为二维laserscan。去除合并雷达不同高度的信息。
        trans2Scan(Point(lidar_origin.x(), lidar_origin.y()));

        // 经过的栅格后，替换地图中的数据
        // 绘制未占用的栅格
        for (auto pt : affectScan)
        {
            IntPoint temp_pt;
            temp_pt = transToMap(Point(pt.x, pt.y));
            // Bresenham算法计算经过的栅格
            GridLineTraversalLine line;
            GridLineTraversal::gridLine(lidar_pose, temp_pt, &line);
            for (auto mapPixel : line.points)
            {
                setMapPiexlFree(mapPixel);
            }
        }

        // 绘制占用的栅格
        for (auto pt : affectCloud)
        {
            IntPoint temp_pt;
            temp_pt = transToMap(Point(pt.x, pt.y));
            setMapPiexlOccupid(temp_pt);
        }
        // std::cout << "---------------" << std::endl;
        // IntPoint origin = transToMap(Point(0.0, 0.0));
        // std::cout << "center" << mapCenter.x << " " << mapCenter.y << std::endl;
        // Point temp = transFromMap(IntPoint(0, 0));
        // std::cout << "origin" << origin.x << " " << origin.y << std::endl;
        // std::cout << "Width | Height" << mapWidth << " " << mapHeight << std::endl;

        // 发布新的地图
        publishMap(stamp);
    }

    void dynamic_map::publishMap(ros::Time &stamp)
    {
        nav_msgs::OccupancyGrid mapMsg;
        mapMsg.header.frame_id = mapFrameId;
        mapMsg.header.stamp = ros::Time::now();
        mapMsg.info.resolution = mapResolution;
        mapMsg.info.width = mapWidth;
        mapMsg.info.height = mapHeight;
        Point originPose = transFromMap(IntPoint(0.0, mapHeight));
        mapMsg.info.origin.position.x = originPose.x;
        mapMsg.info.origin.position.y = originPose.y;
        mapMsg.info.origin.position.z = 0;
        mapMsg.info.origin.orientation.x = 0;
        mapMsg.info.origin.orientation.y = 0;
        mapMsg.info.origin.orientation.z = 0;
        mapMsg.info.origin.orientation.w = 1;
        mapMsg.data.clear();
        mapMsg.data.resize(mapHeight*mapWidth);
        #pragma omp parallel num_threads(4)
        {
            #pragma omp parallel for
            for (int i = 0; i < mapHeight; i++)
            {
                for (int j = 0; j < mapWidth; j++)
                {
                    // mapMsg.data.push_back(dynamicMap.at<schar>(mapHeight - 1 - i, j));
                    mapMsg.data[i*mapWidth +j] = dynamicMap.at<schar>(mapHeight - 1 - i, j);
                }
            }
        }
        dynamicMapPub.publish(mapMsg);
        occupancyGridToImage(mapMsg);
    }

void dynamic_map::occupancyGridToImage(const nav_msgs::OccupancyGrid msg)
{
    int width = msg.info.width;
    int height = msg.info.height;

    // 创建一个灰度图像，大小为 OccupancyGrid 的宽高
    cv::Mat image(height, width, CV_8UC1);

    // 遍历 OccupancyGrid 数据，将其转换为图像
    for (int y = 0; y < height; ++y)
    {
        for (int x = 0; x < width; ++x)
        {
            int index = x + y * width;
            int8_t occupancy_value = msg.data[index];

            // 将 OccupancyGrid 的值转换为图像的灰度值
            if (occupancy_value == -1)  // 未知区域
            {
                image.at<uchar>(y, x) = 128;  // 灰色
            }
            else if (occupancy_value == 0)  // 空闲区域
            {
                image.at<uchar>(y, x) = 255;  // 白色
            }
            else  // 占用区域
            {
                image.at<uchar>(y, x) = 0;  // 黑色
            }
        }
    }

    // 翻转图像以纠正上下颠倒的问题
    cv::Mat flipped_image;
    cv::flip(image, flipped_image, 0);  // 0 表示垂直翻转（上下翻转）


    // 将图像压缩为 JPEG 格式
    std::vector<uchar> buffer;
    std::vector<int> params = {cv::IMWRITE_JPEG_QUALITY, 90};
    cv::imencode(".jpg", flipped_image, buffer, params);

    // 创建 CompressedImage 消息
    sensor_msgs::CompressedImage compressed_image_msg;
    compressed_image_msg.header.stamp = ros::Time::now();
    compressed_image_msg.header.frame_id = msg.header.frame_id;
    compressed_image_msg.format = "jpeg";
    compressed_image_msg.data = buffer;

    // 发布压缩图像
    image_pub.publish(compressed_image_msg);
}

    void dynamic_map::trans2Scan(Point lidarPose)
    {
        affectScan.clear();
        double zone_theta = 2 * M_PI / zonenum;
        for(int i=0;i < ScanInZone.size();i++)
        {
            ScanInZone[i].clear();
        }

        for (int i = 0; i < affectCloud.size(); i++)
        {
            double len = euclidianDist(Point(affectCloud[i].x, affectCloud[i].y), lidarPose);
            double theta;
            if (affectCloud[i].x == 0 && affectCloud[i].y == 0)
            {
                continue;
            }
            theta = atan2(affectCloud[i].y - lidarPose.y, affectCloud[i].x - lidarPose.x);
            pcl::PointXYZ p;
            p.x = theta;
            p.y = len; 
            p.z = i;
            ScanInZone[int((theta+M_PI) / zone_theta)].push_back(p);
        }
        #pragma omp parallel num_threads(4)
        {
            #pragma omp parallel for
            for (int i = 0; i < zonenum; i++)
            {
                #pragma omp critical
                {
                    sort(ScanInZone[i].begin(), ScanInZone[i].end(), compare_y);
                }
                if (ScanInZone[i].size() > 0)
                {
                    pcl::PointXYZ point;
                    point = affectCloud[ScanInZone[i][0].z];
                    #pragma omp critical
                    {
                        affectScan.push_back(point);
                    }
                }
            }
        }
    }

    void dynamic_map::setMapPiexlFree(IntPoint mapPixel)
    {
        if (dynamicMap.at<schar>(mapPixel.y, mapPixel.x) == -1)
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = 0;
        }
        else
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = dynamicMap.at<schar>(mapPixel.y, mapPixel.x) - 5;
        }

        if (dynamicMap.at<schar>(mapPixel.y, mapPixel.x) < 0)
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = 0;
        }
    }

    void dynamic_map::setMapPiexlOccupid(IntPoint mapPixel)
    {
        if (dynamicMap.at<schar>(mapPixel.y, mapPixel.x) == -1)
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = 100;
        }
        else
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = dynamicMap.at<schar>(mapPixel.y, mapPixel.x) + 10;
        }
        if (dynamicMap.at<schar>(mapPixel.y, mapPixel.x) > 100)
        {
            dynamicMap.at<schar>(mapPixel.y, mapPixel.x) = 100;
        }
    }

    IntPoint dynamic_map::transToMap(Point pose)
    {
        IntPoint temp;
        temp.x = int(pose.x / mapResolution);
        temp.y = int(pose.y / mapResolution);
        IntPoint result;
        result.x = temp.x + mapCenter.x;
        result.y = mapCenter.y - temp.y;
        return result;
    }

    Point dynamic_map::transFromMap(IntPoint pose)
    {
        IntPoint temp;
        temp.x = pose.x - mapCenter.x;
        temp.y = -pose.y + mapCenter.y;
        Point result;
        result.x = temp.x * mapResolution;
        result.y = temp.y * mapResolution;
        return result;
    }

    void dynamic_map::mapExpand(IntPoint expendSize)
    {
        if (expendSize.x >= 0 && expendSize.y >= 0)
        {
            cv::copyMakeBorder(dynamicMap, dynamicMap, 0, expendSize.y, 0, expendSize.x, cv::BORDER_REPLICATE);
            // 原点不动
            mapWidth = mapWidth + expendSize.x;
            mapHeight = mapHeight + expendSize.y;
        }
        if (expendSize.x >= 0 && expendSize.y < 0)
        {
            cv::copyMakeBorder(dynamicMap, dynamicMap, -expendSize.y, 0, 0, expendSize.x, cv::BORDER_REPLICATE);
            mapCenter.y = mapCenter.y - expendSize.y;
            mapWidth = mapWidth + expendSize.x;
            mapHeight = mapHeight - expendSize.y;
        }
        if (expendSize.x < 0 && expendSize.y >= 0)
        {
            cv::copyMakeBorder(dynamicMap, dynamicMap, 0, expendSize.y, -expendSize.x, 0, cv::BORDER_REPLICATE);
            mapCenter.x = mapCenter.x - expendSize.x;
            mapWidth = mapWidth - expendSize.x;
            mapHeight = mapHeight + expendSize.y;
        }
        if (expendSize.x < 0 && expendSize.y < 0)
        {
            cv::copyMakeBorder(dynamicMap, dynamicMap, -expendSize.y, 0, -expendSize.x, 0, cv::BORDER_REPLICATE);
            mapCenter.y = mapCenter.y - expendSize.y;
            mapCenter.x = mapCenter.x - expendSize.x;
            mapWidth = mapWidth - expendSize.x;
            mapHeight = mapHeight - expendSize.y;
        }
    }

    void dynamic_map::mapExpand(int top, int bottom, int left, int right)
    {
        // 防御 1：拒绝负数
        if (top < 0 || bottom < 0 || left < 0 || right < 0) {
            ROS_ERROR("mapExpand invalid params! top:%d, bottom:%d, left:%d, right:%d", top, bottom, left, right);
            return;
        }

        // 防御 2：预防 OpenCV 内部计算新尺寸时发生 int 溢出
        // 限制地图最大宽高 (例如不超过 20000x20000 栅格，防止把电脑内存吃光)
        long long new_width = (long long)this->mapWidth + left + right;
        long long new_height = (long long)this->mapHeight + top + bottom;
        
        if (new_width > 20000 || new_height > 20000) {
            ROS_ERROR("mapExpand refused! Map would become too large: %lld x %lld", new_width, new_height);
            return;
        }

        // cv::Mat temp;
        // cv::copyMakeBorder(dynamicMap, temp, top, bottom, left, right, cv::BORDER_REPLICATE);
        cv::copyMakeBorder(dynamicMap, dynamicMap, top, bottom, left, right, cv::BORDER_CONSTANT, cv::Scalar(-1));
        // this->dynamicMap = temp;
        this->mapCenter.y = this->mapCenter.y + top;
        this->mapCenter.x = this->mapCenter.x + left;
        this->mapWidth = this->mapWidth + left + right;
        this->mapHeight = this->mapHeight + top + bottom;
    }
}
