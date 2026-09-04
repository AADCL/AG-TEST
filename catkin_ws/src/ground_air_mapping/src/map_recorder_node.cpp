#include <algorithm>
#include <cerrno>
#include <cstdint>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <memory>
#include <mutex>
#include <regex>
#include <sstream>
#include <string>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>
#include <vector>

#include <Eigen/Geometry>
#include <ground_air_mapping/static_map_filter.hpp>
#include <ground_air_msgs/MappingStatus.h>
#include <ground_air_msgs/SaveMapping.h>
#include <ground_air_msgs/StartMapping.h>
#include <nav_msgs/Odometry.h>
#include <nav_msgs/OccupancyGrid.h>
#include <pcl/common/point_tests.h>
#include <pcl/filters/radius_outlier_removal.h>
#include <pcl/filters/voxel_grid.h>
#include <pcl/point_cloud.h>
#include <pcl/point_types.h>
#include <pcl_conversions/pcl_conversions.h>
#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>
#include <std_msgs/Header.h>
#include <std_srvs/Trigger.h>

namespace {

using PclPoint = pcl::PointXYZI;
using PclCloud = pcl::PointCloud<PclPoint>;

bool pathExists(const std::string& path) {
    struct stat info {};
    return ::stat(path.c_str(), &info) == 0;
}

bool ensureDirectory(const std::string& path, std::string& error) {
    if (path.empty() || path == "/") return true;
    std::string current;
    if (path.front() == '/') current = "/";
    std::stringstream stream(path);
    std::string part;
    while (std::getline(stream, part, '/')) {
        if (part.empty()) continue;
        if (current.size() > 1 && current.back() != '/') current += '/';
        current += part;
        if (::mkdir(current.c_str(), 0755) != 0 && errno != EEXIST) {
            error = "cannot create directory " + current + ": " + std::strerror(errno);
            return false;
        }
    }
    return true;
}

void removeStagingBundle(const std::string& directory) {
    for (const char* name : {"cloud_map.pcd", "map.pgm", "map.yaml", "metadata.json"}) {
        ::unlink((directory + "/" + name).c_str());
    }
    ::rmdir(directory.c_str());
}

double mapArea(const nav_msgs::OccupancyGrid& map) {
    std::size_t known = 0;
    for (const auto value : map.data) {
        if (value >= 0) ++known;
    }
    return static_cast<double>(known) * map.info.resolution * map.info.resolution;
}

bool writePcd(const std::string& path,
              const std::vector<ground_air_mapping::Point3d>& points,
              std::string& error) {
    std::ofstream out(path, std::ios::binary);
    if (!out) {
        error = "cannot open " + path;
        return false;
    }
    out << "# .PCD v0.7 - Point Cloud Data file format\n"
        << "VERSION 0.7\nFIELDS x y z\nSIZE 4 4 4\nTYPE F F F\n"
        << "COUNT 1 1 1\nWIDTH " << points.size() << "\nHEIGHT 1\n"
        << "VIEWPOINT 0 0 0 1 0 0 0\nPOINTS " << points.size()
        << "\nDATA binary\n";
    for (const auto& point : points) {
        const float xyz[3] = {static_cast<float>(point.x), static_cast<float>(point.y),
                              static_cast<float>(point.z)};
        out.write(reinterpret_cast<const char*>(xyz), sizeof(xyz));
    }
    if (!out) {
        error = "failed while writing " + path;
        return false;
    }
    return true;
}

bool writePgm(const std::string& path, const nav_msgs::OccupancyGrid& map,
              std::string& error) {
    std::ofstream out(path, std::ios::binary);
    if (!out) {
        error = "cannot open " + path;
        return false;
    }
    out << "P5\n# CREATOR: ground_air_mapping\n" << map.info.width << ' '
        << map.info.height << "\n255\n";
    for (int y = static_cast<int>(map.info.height) - 1; y >= 0; --y) {
        for (std::uint32_t x = 0; x < map.info.width; ++x) {
            const auto cell = map.data[static_cast<std::size_t>(y) * map.info.width + x];
            unsigned char value = 205;
            if (cell >= 65) value = 0;
            else if (cell >= 0 && cell <= 19) value = 254;
            out.write(reinterpret_cast<const char*>(&value), 1);
        }
    }
    if (!out) {
        error = "failed while writing " + path;
        return false;
    }
    return true;
}

bool writeYaml(const std::string& path, const nav_msgs::OccupancyGrid& map,
               std::string& error) {
    std::ofstream out(path);
    if (!out) {
        error = "cannot open " + path;
        return false;
    }
    const auto& q = map.info.origin.orientation;
    const double yaw = std::atan2(2.0 * (q.w * q.z + q.x * q.y),
                                  1.0 - 2.0 * (q.y * q.y + q.z * q.z));
    out << std::setprecision(12)
        << "image: map.pgm\nresolution: " << map.info.resolution << "\norigin: ["
        << map.info.origin.position.x << ", " << map.info.origin.position.y << ", "
        << yaw << "]\nnegate: 0\noccupied_thresh: 0.65\nfree_thresh: 0.196\n";
    if (!out) {
        error = "failed while writing " + path;
        return false;
    }
    return true;
}

bool writeMetadata(const std::string& path, const std::string& map_id,
                   std::size_t points, double area, double voxel_size,
                   std::string& error) {
    std::ofstream out(path);
    if (!out) {
        error = "cannot open " + path;
        return false;
    }
    out << "{\n"
        << "  \"map_id\": \"" << map_id << "\",\n"
        << "  \"frame_id\": \"map\",\n"
        << "  \"point_cloud\": \"cloud_map.pcd\",\n"
        << "  \"occupancy_map\": \"map.yaml\",\n"
        << "  \"voxel_size\": " << voxel_size << ",\n"
        << "  \"point_count\": " << points << ",\n"
        << "  \"map_area\": " << area << "\n"
        << "}\n";
    if (!out) {
        error = "failed while writing " + path;
        return false;
    }
    return true;
}

}  // namespace

class MapRecorderNode {
public:
    MapRecorderNode() : nh_(), pnh_("~") {
        pnh_.param<std::string>("maps_root", maps_root_, "/home/bitcq/catkin_ws/maps");
        pnh_.param<std::string>("scan_topic", scan_topic_, "/cloud_registered");
        pnh_.param<std::string>("odometry_topic", odometry_topic_, "/Odometry");
        pnh_.param<std::string>("map_topic", map_topic_, "/map");
        pnh_.param<std::string>("expected_scan_frame", expected_scan_frame_, "camera_init");
        pnh_.param<std::string>("static_cloud_topic", static_cloud_topic_,
                                "/ground_air/mapping/static_cloud");
        pnh_.param<std::string>("dynamic_points_topic", dynamic_points_topic_,
                                "/ground_air/mapping/dynamic_points");
        pnh_.param("voxel_size", voxel_size_, 0.10);
        int max_voxels = 5000000;
        int min_points = 500;
        pnh_.param("max_voxels", max_voxels, max_voxels);
        pnh_.param("min_points", min_points, min_points);
        max_voxels_ = static_cast<std::size_t>(std::max(1, max_voxels));
        min_points_ = static_cast<std::size_t>(std::max(1, min_points));

        ground_air_mapping::StaticMapFilterConfig filter_config;
        int min_hit_scans = 8;
        int ray_stride = 4;
        int max_temporal_voxels = 2000000;
        pnh_.param("min_range", min_range_, 0.50);
        pnh_.param("max_range", max_range_, 50.0);
        pnh_.param("scan_voxel_size", scan_voxel_size_, 0.05);
        pnh_.param("radius_filter_enable", radius_filter_enable_, true);
        pnh_.param("radius", radius_, 0.15);
        pnh_.param("min_neighbors", min_neighbors_, 2);
        pnh_.param("self_filter_enable", self_filter_enable_, false);
        pnh_.param("self_min_x", self_min_x_, -0.35);
        pnh_.param("self_max_x", self_max_x_, 0.35);
        pnh_.param("self_min_y", self_min_y_, -0.35);
        pnh_.param("self_max_y", self_max_y_, 0.35);
        pnh_.param("self_min_z", self_min_z_, -0.40);
        pnh_.param("self_max_z", self_max_z_, 0.30);
        pnh_.param("temporal_voxel_size", filter_config.temporal_voxel_size, 0.20);
        pnh_.param("hit_probability", filter_config.hit_probability, 0.70);
        pnh_.param("miss_probability", filter_config.miss_probability, 0.40);
        pnh_.param("occupied_probability", filter_config.occupied_probability, 0.72);
        pnh_.param("clearing_probability", filter_config.clearing_probability, 0.35);
        pnh_.param("min_hit_scans", min_hit_scans, 8);
        pnh_.param("min_observation_span", filter_config.min_observation_span, 2.0);
        pnh_.param("ray_stride", ray_stride, 4);
        pnh_.param("max_clearing_range", filter_config.max_clearing_range, 20.0);
        pnh_.param("ray_endpoint_margin", filter_config.ray_endpoint_margin, 0.30);
        pnh_.param("candidate_timeout", filter_config.candidate_timeout, 5.0);
        pnh_.param("cleanup_period", filter_config.cleanup_period, 1.0);
        pnh_.param("max_temporal_voxels", max_temporal_voxels, 2000000);
        pnh_.param("max_odom_age", max_odom_age_, 0.20);
        pnh_.param("static_publish_period", static_publish_period_, 2.0);
        pnh_.param("publish_dynamic_points", publish_dynamic_points_, false);
        min_range_ = std::max(0.0, min_range_);
        max_range_ = std::max(min_range_, max_range_);
        scan_voxel_size_ = std::max(0.01, scan_voxel_size_);
        radius_ = std::max(0.01, radius_);
        min_neighbors_ = std::max(1, min_neighbors_);
        max_odom_age_ = std::max(0.0, max_odom_age_);
        static_publish_period_ = std::max(0.1, static_publish_period_);
        filter_config.map_voxel_size = voxel_size_;
        filter_config.max_map_voxels = max_voxels_;
        filter_config.max_temporal_voxels =
            static_cast<std::size_t>(std::max(1, max_temporal_voxels));
        filter_config.min_hit_scans =
            static_cast<std::uint32_t>(std::max(1, min_hit_scans));
        filter_config.ray_stride = static_cast<std::size_t>(std::max(1, ray_stride));
        map_filter_.reset(new ground_air_mapping::StaticMapFilter(filter_config));

        scan_sub_ = nh_.subscribe(scan_topic_, 2, &MapRecorderNode::scanCallback, this);
        odometry_sub_ = nh_.subscribe(odometry_topic_, 20,
                                      &MapRecorderNode::odometryCallback, this);
        map_sub_ = nh_.subscribe(map_topic_, 1, &MapRecorderNode::mapCallback, this);
        status_pub_ = nh_.advertise<ground_air_msgs::MappingStatus>(
            "/ground_air/mapping/status", 1, true);
        static_cloud_pub_ = nh_.advertise<sensor_msgs::PointCloud2>(
            static_cloud_topic_, 1, true);
        if (publish_dynamic_points_) {
            dynamic_points_pub_ = nh_.advertise<sensor_msgs::PointCloud2>(
                dynamic_points_topic_, 1);
        }
        start_srv_ = nh_.advertiseService("/ground_air/mapping/start",
                                          &MapRecorderNode::start, this);
        save_srv_ = nh_.advertiseService("/ground_air/mapping/save",
                                         &MapRecorderNode::save, this);
        cancel_srv_ = nh_.advertiseService("/ground_air/mapping/cancel",
                                           &MapRecorderNode::cancel, this);
        publishStatus();
        ROS_INFO("[ground_air_mapping] filtered mapping: %s + %s -> %s",
                 scan_topic_.c_str(), odometry_topic_.c_str(),
                 static_cloud_topic_.c_str());
    }

private:
    ground_air_msgs::MappingStatus statusLocked() const {
        ground_air_msgs::MappingStatus status;
        status.header.stamp = ros::Time::now();
        status.state = state_;
        status.map_id = map_id_;
        status.point_count = state_ == ground_air_msgs::MappingStatus::COMPLETE
                                 ? saved_point_count_
                                 : filtered_point_count_;
        status.map_area = map_area_;
        status.message = message_;
        return status;
    }

    ground_air_msgs::MappingStatus status() const {
        std::lock_guard<std::mutex> lock(mutex_);
        return statusLocked();
    }

    void publishStatus() { status_pub_.publish(status()); }

    void fail(const std::string& message) {
        {
            std::lock_guard<std::mutex> lock(mutex_);
            state_ = ground_air_msgs::MappingStatus::ERROR;
            message_ = message;
        }
        publishStatus();
        ROS_ERROR("[ground_air_mapping] %s", message.c_str());
    }

    void odometryCallback(const nav_msgs::Odometry::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(mutex_);
        latest_odometry_ = *msg;
        have_odometry_ = true;
    }

    bool sensorPoseLocked(const sensor_msgs::PointCloud2& cloud,
                          ground_air_mapping::Point3d& sensor_position,
                          Eigen::Quaterniond& orientation) const {
        if (!have_odometry_) {
            ROS_WARN_THROTTLE(2.0, "[ground_air_mapping] waiting for /Odometry");
            return false;
        }
        if (!cloud.header.frame_id.empty() && cloud.header.frame_id != expected_scan_frame_) {
            ROS_ERROR_THROTTLE(2.0,
                               "[ground_air_mapping] scan frame '%s', expected '%s'",
                               cloud.header.frame_id.c_str(), expected_scan_frame_.c_str());
            return false;
        }
        if (!latest_odometry_.header.frame_id.empty() &&
            latest_odometry_.header.frame_id != expected_scan_frame_) {
            ROS_ERROR_THROTTLE(2.0,
                               "[ground_air_mapping] odometry frame '%s', expected '%s'",
                               latest_odometry_.header.frame_id.c_str(), expected_scan_frame_.c_str());
            return false;
        }
        if (!cloud.header.stamp.isZero() && !latest_odometry_.header.stamp.isZero()) {
            const double age = std::fabs(
                (cloud.header.stamp - latest_odometry_.header.stamp).toSec());
            if (age > max_odom_age_) {
                ROS_WARN_THROTTLE(2.0,
                                  "[ground_air_mapping] scan/odometry age %.3f s exceeds %.3f s",
                                  age, max_odom_age_);
                return false;
            }
        }
        const auto& pose = latest_odometry_.pose.pose;
        sensor_position = {pose.position.x, pose.position.y, pose.position.z};
        orientation = Eigen::Quaterniond(pose.orientation.w, pose.orientation.x,
                                         pose.orientation.y, pose.orientation.z);
        if (!std::isfinite(sensor_position.x) || !std::isfinite(sensor_position.y) ||
            !std::isfinite(sensor_position.z) || !std::isfinite(orientation.norm()) ||
            orientation.norm() < 1e-6) {
            ROS_WARN_THROTTLE(2.0, "[ground_air_mapping] invalid odometry pose");
            return false;
        }
        orientation.normalize();
        return true;
    }

    std::vector<ground_air_mapping::Point3d> prefilterLocked(
            const sensor_msgs::PointCloud2& msg,
            const ground_air_mapping::Point3d& sensor_position,
            const Eigen::Quaterniond& orientation) const {
        PclCloud::Ptr input(new PclCloud);
        pcl::fromROSMsg(msg, *input);
        PclCloud::Ptr valid(new PclCloud);
        valid->reserve(input->size());
        const Eigen::Vector3d sensor(sensor_position.x, sensor_position.y,
                                     sensor_position.z);
        const Eigen::Quaterniond world_to_body = orientation.conjugate();
        const double min_range_sq = min_range_ * min_range_;
        const double max_range_sq = max_range_ * max_range_;
        for (const PclPoint& point : input->points) {
            if (!pcl::isFinite(point)) continue;
            const Eigen::Vector3d world_point(point.x, point.y, point.z);
            const Eigen::Vector3d body_point = world_to_body * (world_point - sensor);
            const double range_sq = body_point.squaredNorm();
            if (range_sq < min_range_sq || range_sq > max_range_sq) continue;
            if (self_filter_enable_ && body_point.x() >= self_min_x_ &&
                body_point.x() <= self_max_x_ && body_point.y() >= self_min_y_ &&
                body_point.y() <= self_max_y_ && body_point.z() >= self_min_z_ &&
                body_point.z() <= self_max_z_) {
                continue;
            }
            valid->push_back(point);
        }

        PclCloud::Ptr downsampled(new PclCloud);
        pcl::VoxelGrid<PclPoint> voxel;
        voxel.setLeafSize(scan_voxel_size_, scan_voxel_size_, scan_voxel_size_);
        voxel.setInputCloud(valid);
        voxel.filter(*downsampled);

        PclCloud::Ptr filtered = downsampled;
        if (radius_filter_enable_ && !downsampled->empty()) {
            filtered.reset(new PclCloud);
            pcl::RadiusOutlierRemoval<PclPoint> radius_filter;
            radius_filter.setInputCloud(downsampled);
            radius_filter.setRadiusSearch(radius_);
            radius_filter.setMinNeighborsInRadius(std::max(1, min_neighbors_));
            radius_filter.filter(*filtered);
        }

        std::vector<ground_air_mapping::Point3d> result;
        result.reserve(filtered->size());
        for (const PclPoint& point : filtered->points) {
            result.push_back({point.x, point.y, point.z});
        }
        return result;
    }

    void publishPointsLocked(const std::vector<ground_air_mapping::Point3d>& points,
                             const std_msgs::Header& header,
                             const ros::Publisher& publisher) const {
        PclCloud cloud;
        cloud.reserve(points.size());
        for (const auto& point : points) {
            PclPoint output;
            output.x = static_cast<float>(point.x);
            output.y = static_cast<float>(point.y);
            output.z = static_cast<float>(point.z);
            output.intensity = 0.0f;
            cloud.push_back(output);
        }
        sensor_msgs::PointCloud2 message;
        pcl::toROSMsg(cloud, message);
        message.header = header;
        publisher.publish(message);
    }

    void publishEmptyDiagnosticsLocked() const {
        std_msgs::Header header;
        header.stamp = ros::Time::now();
        header.frame_id = expected_scan_frame_;
        publishPointsLocked({}, header, static_cloud_pub_);
        if (publish_dynamic_points_) {
            publishPointsLocked({}, header, dynamic_points_pub_);
        }
    }

    void scanCallback(const sensor_msgs::PointCloud2::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (state_ != ground_air_msgs::MappingStatus::RECORDING) return;
        ground_air_mapping::Point3d sensor_position;
        Eigen::Quaterniond orientation;
        if (!sensorPoseLocked(*msg, sensor_position, orientation)) return;

        std::vector<ground_air_mapping::Point3d> filtered;
        try {
            filtered = prefilterLocked(*msg, sensor_position, orientation);
        } catch (const std::exception& error) {
            ROS_ERROR_THROTTLE(2.0, "[ground_air_mapping] point-cloud filter failed: %s",
                               error.what());
            return;
        }
        const ros::Time filter_time = msg->header.stamp.isZero() ? ros::Time::now()
                                                                 : msg->header.stamp;
        map_filter_->updateScan(filtered, sensor_position, filter_time.toSec());
        if (map_filter_->capacityExceeded()) {
            state_ = ground_air_msgs::MappingStatus::ERROR;
            message_ = "static-map filter capacity exceeded; map recording stopped";
            status_pub_.publish(statusLocked());
            return;
        }

        if (publish_dynamic_points_) {
            std::vector<ground_air_mapping::Point3d> dynamic_points;
            dynamic_points.reserve(filtered.size());
            for (const auto& point : filtered) {
                if (!map_filter_->isStaticPoint(point)) dynamic_points.push_back(point);
            }
            publishPointsLocked(dynamic_points, msg->header, dynamic_points_pub_);
        }

        const ros::Time now = filter_time;
        if (last_static_publish_.isZero() ||
            (now - last_static_publish_).toSec() < 0.0 ||
            (now - last_static_publish_).toSec() >= static_publish_period_) {
            const auto static_points = map_filter_->points();
            filtered_point_count_ = static_points.size();
            publishPointsLocked(static_points, msg->header, static_cloud_pub_);
            last_static_publish_ = now;
        }
        status_pub_.publish(statusLocked());
    }

    void mapCallback(const nav_msgs::OccupancyGrid::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (state_ != ground_air_msgs::MappingStatus::RECORDING) return;
        latest_map_ = *msg;
        have_map_ = msg->info.width > 0 && msg->info.height > 0 && !msg->data.empty();
        map_area_ = have_map_ ? mapArea(latest_map_) : 0.0;
    }

    bool start(ground_air_msgs::StartMapping::Request& request,
               ground_air_msgs::StartMapping::Response& response) {
        static const std::regex pattern("^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$");
        std::lock_guard<std::mutex> lock(mutex_);
        if (!std::regex_match(request.map_id, pattern)) {
            response.message = "invalid map_id";
        } else if (state_ == ground_air_msgs::MappingStatus::RECORDING ||
                   state_ == ground_air_msgs::MappingStatus::SAVING) {
            response.message = "another mapping session is active";
        } else if (pathExists(maps_root_ + "/" + request.map_id)) {
            response.message = "destination already exists";
        } else {
            map_filter_->clear();
            publishEmptyDiagnosticsLocked();
            latest_map_ = nav_msgs::OccupancyGrid();
            have_map_ = false;
            saved_point_count_ = 0;
            filtered_point_count_ = 0;
            last_static_publish_ = ros::Time();
            map_area_ = 0.0;
            map_id_ = request.map_id;
            state_ = ground_air_msgs::MappingStatus::RECORDING;
            message_ = "recording filtered static point cloud and occupancy map";
            response.success = true;
            response.message = message_;
        }
        response.status = statusLocked();
        status_pub_.publish(response.status);
        return true;
    }

    bool save(ground_air_msgs::SaveMapping::Request&,
              ground_air_msgs::SaveMapping::Response& response) {
        std::vector<ground_air_mapping::Point3d> points;
        nav_msgs::OccupancyGrid map;
        std::string map_id;
        {
            std::lock_guard<std::mutex> lock(mutex_);
            if (state_ != ground_air_msgs::MappingStatus::RECORDING) {
                response.message = "no active mapping session";
                response.status = statusLocked();
                return true;
            }
            if (map_filter_->capacityExceeded()) {
                response.message = "voxel capacity exceeded";
                response.status = statusLocked();
                return true;
            }
            points = map_filter_->points();
            filtered_point_count_ = points.size();
            if (points.size() < min_points_) {
                response.message = "point cloud has too few accumulated voxels";
                response.status = statusLocked();
                return true;
            }
            if (!have_map_) {
                response.message = "no occupancy grid received during this session";
                response.status = statusLocked();
                return true;
            }
            state_ = ground_air_msgs::MappingStatus::SAVING;
            message_ = "saving map bundle";
            map = latest_map_;
            map_id = map_id_;
            status_pub_.publish(statusLocked());
        }

        const std::string destination = maps_root_ + "/" + map_id;
        const std::string staging = maps_root_ + "/.staging-" + map_id + "-" +
                                    std::to_string(static_cast<long long>(::getpid()));
        std::string error;
        if (!ensureDirectory(maps_root_, error)) {
            fail(error);
        } else if (pathExists(destination)) {
            fail("destination already exists");
        } else {
            removeStagingBundle(staging);
            if (!ensureDirectory(staging, error) ||
                !writePcd(staging + "/cloud_map.pcd", points, error) ||
                !writePgm(staging + "/map.pgm", map, error) ||
                !writeYaml(staging + "/map.yaml", map, error) ||
                !writeMetadata(staging + "/metadata.json", map_id, points.size(),
                               mapArea(map), voxel_size_, error) ||
                ::rename(staging.c_str(), destination.c_str()) != 0) {
                if (error.empty()) error = std::string("rename failed: ") + std::strerror(errno);
                removeStagingBundle(staging);
                fail(error);
            } else {
                std::lock_guard<std::mutex> lock(mutex_);
                state_ = ground_air_msgs::MappingStatus::COMPLETE;
                saved_point_count_ = points.size();
                map_area_ = mapArea(map);
                message_ = "map bundle saved";
                map_filter_->clear();
                publishEmptyDiagnosticsLocked();
                filtered_point_count_ = 0;
            }
        }

        response.status = status();
        response.success = response.status.state == ground_air_msgs::MappingStatus::COMPLETE;
        response.message = response.status.message;
        if (response.success) response.map_directory = destination;
        response.point_count = response.status.point_count;
        response.map_area = response.status.map_area;
        status_pub_.publish(response.status);
        return true;
    }

    bool cancel(std_srvs::Trigger::Request&, std_srvs::Trigger::Response& response) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (state_ == ground_air_msgs::MappingStatus::SAVING) {
            response.message = "cannot cancel while saving";
            return true;
        }
        map_filter_->clear();
        publishEmptyDiagnosticsLocked();
        latest_map_ = nav_msgs::OccupancyGrid();
        have_map_ = false;
        map_id_.clear();
        map_area_ = 0.0;
        saved_point_count_ = 0;
        filtered_point_count_ = 0;
        last_static_publish_ = ros::Time();
        state_ = ground_air_msgs::MappingStatus::IDLE;
        message_ = "mapping session cancelled";
        response.success = true;
        response.message = message_;
        status_pub_.publish(statusLocked());
        return true;
    }

    ros::NodeHandle nh_;
    ros::NodeHandle pnh_;
    ros::Subscriber scan_sub_;
    ros::Subscriber odometry_sub_;
    ros::Subscriber map_sub_;
    ros::Publisher status_pub_;
    ros::Publisher static_cloud_pub_;
    ros::Publisher dynamic_points_pub_;
    ros::ServiceServer start_srv_;
    ros::ServiceServer save_srv_;
    ros::ServiceServer cancel_srv_;

    mutable std::mutex mutex_;
    std::unique_ptr<ground_air_mapping::StaticMapFilter> map_filter_;
    nav_msgs::Odometry latest_odometry_;
    nav_msgs::OccupancyGrid latest_map_;
    bool have_odometry_ = false;
    bool have_map_ = false;
    std::uint8_t state_ = ground_air_msgs::MappingStatus::IDLE;
    std::string map_id_;
    std::string message_ = "idle";
    std::size_t saved_point_count_ = 0;
    std::size_t filtered_point_count_ = 0;
    double map_area_ = 0.0;
    ros::Time last_static_publish_;

    std::string maps_root_;
    std::string scan_topic_;
    std::string odometry_topic_;
    std::string map_topic_;
    std::string expected_scan_frame_;
    std::string static_cloud_topic_;
    std::string dynamic_points_topic_;
    double voxel_size_ = 0.10;
    std::size_t max_voxels_ = 5000000;
    std::size_t min_points_ = 500;
    double min_range_ = 0.50;
    double max_range_ = 50.0;
    double scan_voxel_size_ = 0.05;
    bool radius_filter_enable_ = true;
    double radius_ = 0.15;
    int min_neighbors_ = 2;
    bool self_filter_enable_ = false;
    double self_min_x_ = -0.35;
    double self_max_x_ = 0.35;
    double self_min_y_ = -0.35;
    double self_max_y_ = 0.35;
    double self_min_z_ = -0.40;
    double self_max_z_ = 0.30;
    double max_odom_age_ = 0.20;
    double static_publish_period_ = 2.0;
    bool publish_dynamic_points_ = false;
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "ground_air_map_recorder");
    MapRecorderNode node;
    ros::spin();
    return 0;
}
