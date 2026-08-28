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

#include <ground_air_mapping/voxel_accumulator.hpp>
#include <ground_air_msgs/MappingStatus.h>
#include <ground_air_msgs/SaveMapping.h>
#include <ground_air_msgs/StartMapping.h>
#include <nav_msgs/OccupancyGrid.h>
#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>
#include <sensor_msgs/point_cloud2_iterator.h>
#include <std_srvs/Trigger.h>

namespace {

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
        << "  \"frame_id\": \"world\",\n"
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
        pnh_.param<std::string>("map_topic", map_topic_, "/map");
        pnh_.param<std::string>("expected_scan_frame", expected_scan_frame_, "camera_init");
        pnh_.param("voxel_size", voxel_size_, 0.10);
        int max_voxels = 5000000;
        int min_points = 500;
        pnh_.param("max_voxels", max_voxels, max_voxels);
        pnh_.param("min_points", min_points, min_points);
        max_voxels_ = static_cast<std::size_t>(std::max(1, max_voxels));
        min_points_ = static_cast<std::size_t>(std::max(1, min_points));
        accumulator_.reset(new ground_air_mapping::VoxelAccumulator(voxel_size_, max_voxels_));

        scan_sub_ = nh_.subscribe(scan_topic_, 2, &MapRecorderNode::scanCallback, this);
        map_sub_ = nh_.subscribe(map_topic_, 1, &MapRecorderNode::mapCallback, this);
        status_pub_ = nh_.advertise<ground_air_msgs::MappingStatus>(
            "/ground_air/mapping/status", 1, true);
        start_srv_ = nh_.advertiseService("/ground_air/mapping/start",
                                          &MapRecorderNode::start, this);
        save_srv_ = nh_.advertiseService("/ground_air/mapping/save",
                                         &MapRecorderNode::save, this);
        cancel_srv_ = nh_.advertiseService("/ground_air/mapping/cancel",
                                           &MapRecorderNode::cancel, this);
        publishStatus();
    }

private:
    ground_air_msgs::MappingStatus statusLocked() const {
        ground_air_msgs::MappingStatus status;
        status.header.stamp = ros::Time::now();
        status.state = state_;
        status.map_id = map_id_;
        status.point_count = state_ == ground_air_msgs::MappingStatus::COMPLETE
                                 ? saved_point_count_
                                 : accumulator_->size();
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

    void scanCallback(const sensor_msgs::PointCloud2::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(mutex_);
        if (state_ != ground_air_msgs::MappingStatus::RECORDING) return;
        if (!msg->header.frame_id.empty() && msg->header.frame_id != expected_scan_frame_) {
            state_ = ground_air_msgs::MappingStatus::ERROR;
            message_ = "scan frame mismatch: expected " + expected_scan_frame_ +
                       ", received " + msg->header.frame_id;
            status_pub_.publish(statusLocked());
            return;
        }
        try {
            sensor_msgs::PointCloud2ConstIterator<float> x(*msg, "x");
            sensor_msgs::PointCloud2ConstIterator<float> y(*msg, "y");
            sensor_msgs::PointCloud2ConstIterator<float> z(*msg, "z");
            for (; x != x.end(); ++x, ++y, ++z) accumulator_->add(*x, *y, *z);
        } catch (const std::runtime_error& error) {
            state_ = ground_air_msgs::MappingStatus::ERROR;
            message_ = std::string("PointCloud2 conversion failed: ") + error.what();
        }
        if (accumulator_->capacityExceeded()) {
            state_ = ground_air_msgs::MappingStatus::ERROR;
            message_ = "voxel capacity exceeded; map recording stopped";
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
            accumulator_->clear();
            latest_map_ = nav_msgs::OccupancyGrid();
            have_map_ = false;
            saved_point_count_ = 0;
            map_area_ = 0.0;
            map_id_ = request.map_id;
            state_ = ground_air_msgs::MappingStatus::RECORDING;
            message_ = "recording registered point cloud and occupancy map";
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
            if (accumulator_->capacityExceeded()) {
                response.message = "voxel capacity exceeded";
                response.status = statusLocked();
                return true;
            }
            if (accumulator_->size() < min_points_) {
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
            points = accumulator_->centroids();
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
                accumulator_->clear();
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
        accumulator_->clear();
        latest_map_ = nav_msgs::OccupancyGrid();
        have_map_ = false;
        map_id_.clear();
        map_area_ = 0.0;
        saved_point_count_ = 0;
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
    ros::Subscriber map_sub_;
    ros::Publisher status_pub_;
    ros::ServiceServer start_srv_;
    ros::ServiceServer save_srv_;
    ros::ServiceServer cancel_srv_;

    mutable std::mutex mutex_;
    std::unique_ptr<ground_air_mapping::VoxelAccumulator> accumulator_;
    nav_msgs::OccupancyGrid latest_map_;
    bool have_map_ = false;
    std::uint8_t state_ = ground_air_msgs::MappingStatus::IDLE;
    std::string map_id_;
    std::string message_ = "idle";
    std::size_t saved_point_count_ = 0;
    double map_area_ = 0.0;

    std::string maps_root_;
    std::string scan_topic_;
    std::string map_topic_;
    std::string expected_scan_frame_;
    double voxel_size_ = 0.10;
    std::size_t max_voxels_ = 5000000;
    std::size_t min_points_ = 500;
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "ground_air_map_recorder");
    MapRecorderNode node;
    ros::spin();
    return 0;
}
