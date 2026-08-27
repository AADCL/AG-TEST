#include <atomic>
#include <chrono>
#include <cmath>
#include <condition_variable>
#include <cstdint>
#include <functional>
#include <limits>
#include <memory>
#include <mutex>
#include <string>
#include <stdexcept>
#include <vector>

#include <Eigen/Core>
#include <Eigen/Geometry>
#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/TransformStamped.h>
#include <ground_air_msgs/Relocalize.h>
#include <nav_msgs/Odometry.h>
#include <open3d/Open3D.h>
#include <ros/ros.h>
#include <sensor_msgs/PointCloud2.h>
#include <sensor_msgs/point_cloud2_iterator.h>
#include <std_msgs/Bool.h>
#include <std_msgs/Float64.h>
#include <std_msgs/String.h>

namespace registration = open3d::pipelines::registration;

class GlobalRelocalizer {
public:
    GlobalRelocalizer() : nh_(), pnh_("~") {
        pnh_.param<std::string>("scan_topic", scan_topic_, "/cloud_registered_1");
        pnh_.param<std::string>("odom_topic", odom_topic_, "/Odometry_loc");
        pnh_.param<std::string>("map_frame", map_frame_, "world");
        pnh_.param<std::string>("odom_frame", odom_frame_, "camera_init");
        pnh_.param<std::string>("base_frame", base_frame_, "base_link");
        pnh_.param("coarse_voxel", coarse_voxel_, 0.40);
        pnh_.param("fine_voxel", fine_voxel_, 0.10);
        pnh_.param("min_fitness", min_fitness_, 0.55);
        pnh_.param("max_rmse", max_rmse_, 0.30);
        pnh_.param("required_confirmations", required_confirmations_, 2);
        pnh_.param("min_scan_points", min_scan_points_, 500);
        pnh_.param("ransac_iterations", ransac_iterations_, 100000);
        pnh_.param("scan_stale_timeout", scan_stale_timeout_, 2.0);
        pnh_.param("max_confirmation_translation", max_confirmation_translation_, 0.50);
        pnh_.param("max_confirmation_rotation", max_confirmation_rotation_, 0.35);
        pnh_.param("tracking_failure_limit", tracking_failure_limit_, 3);
        pnh_.param("default_timeout", default_timeout_, 60.0);
        pnh_.param("submap_duration", submap_duration_, 3.0);
        pnh_.param("min_submap_frames", min_submap_frames_, 5);

        scan_sub_ = nh_.subscribe(scan_topic_, 2, &GlobalRelocalizer::scanCallback, this);
        odom_sub_ = nh_.subscribe(odom_topic_, 10, &GlobalRelocalizer::odomCallback, this);
        map_changed_sub_ = nh_.subscribe("/ground_air/localization/map_changed", 1,
                                         &GlobalRelocalizer::mapChangedCallback, this);
        service_ = nh_.advertiseService("/ground_air/relocalize", &GlobalRelocalizer::relocalize, this);
        localized_pub_ = nh_.advertise<std_msgs::Bool>("/ground_air/localization/valid", 1, true);
        fitness_pub_ = nh_.advertise<std_msgs::Float64>("/ground_air/localization/fitness", 1, true);
        rmse_pub_ = nh_.advertise<std_msgs::Float64>("/ground_air/localization/rmse", 1, true);
        pose_pub_ = nh_.advertise<geometry_msgs::PoseStamped>("/ground_air/localization/pose", 1, true);
        map_to_odom_pub_ = nh_.advertise<geometry_msgs::TransformStamped>(
            "/ground_air/localization/map_to_odom", 1, true);
        tracking_timer_ = nh_.createTimer(ros::Duration(1.0), &GlobalRelocalizer::trackingTimer, this);
        setLocalized(false);
    }

private:
    struct PreparedMap {
        std::string path;
        std::shared_ptr<open3d::geometry::PointCloud> coarse;
        std::shared_ptr<registration::Feature> coarse_feature;
        std::shared_ptr<open3d::geometry::PointCloud> fine;
    };

    static Eigen::Matrix4d poseMatrix(const geometry_msgs::Pose& pose) {
        Eigen::Quaterniond q(pose.orientation.w, pose.orientation.x,
                             pose.orientation.y, pose.orientation.z);
        if (q.norm() < 1e-6) q = Eigen::Quaterniond::Identity();
        q.normalize();
        Eigen::Matrix4d matrix = Eigen::Matrix4d::Identity();
        matrix.block<3, 3>(0, 0) = q.toRotationMatrix();
        matrix(0, 3) = pose.position.x;
        matrix(1, 3) = pose.position.y;
        matrix(2, 3) = pose.position.z;
        return matrix;
    }

    static geometry_msgs::Pose matrixPose(const Eigen::Matrix4d& matrix) {
        geometry_msgs::Pose pose;
        pose.position.x = matrix(0, 3);
        pose.position.y = matrix(1, 3);
        pose.position.z = matrix(2, 3);
        Eigen::Quaterniond q(matrix.block<3, 3>(0, 0));
        q.normalize();
        pose.orientation.x = q.x();
        pose.orientation.y = q.y();
        pose.orientation.z = q.z();
        pose.orientation.w = q.w();
        return pose;
    }

    static bool validTransform(const Eigen::Matrix4d& matrix) {
        if (!matrix.allFinite()) return false;
        const double determinant = matrix.block<3, 3>(0, 0).determinant();
        return std::abs(determinant - 1.0) < 0.10 &&
               std::abs(matrix(3, 0)) < 1e-9 && std::abs(matrix(3, 1)) < 1e-9 &&
               std::abs(matrix(3, 2)) < 1e-9 && std::abs(matrix(3, 3) - 1.0) < 1e-9;
    }

    static std::shared_ptr<open3d::geometry::PointCloud> downsampleWithNormals(
            const open3d::geometry::PointCloud& input, double voxel) {
        auto cloud = input.VoxelDownSample(voxel);
        if (!cloud->IsEmpty()) {
            cloud->EstimateNormals(open3d::geometry::KDTreeSearchParamHybrid(voxel * 2.5, 40));
            cloud->OrientNormalsToAlignWithDirection(Eigen::Vector3d(0.0, 0.0, 1.0));
        }
        return cloud;
    }

    void scanCallback(const sensor_msgs::PointCloud2::ConstPtr& msg) {
        open3d::geometry::PointCloud cloud;
        try {
            sensor_msgs::PointCloud2ConstIterator<float> x(*msg, "x");
            sensor_msgs::PointCloud2ConstIterator<float> y(*msg, "y");
            sensor_msgs::PointCloud2ConstIterator<float> z(*msg, "z");
            for (; x != x.end(); ++x, ++y, ++z) {
                if (std::isfinite(*x) && std::isfinite(*y) && std::isfinite(*z)) {
                    cloud.points_.emplace_back(*x, *y, *z);
                }
            }
        } catch (const std::runtime_error& error) {
            ROS_ERROR_THROTTLE(2.0, "PointCloud2 conversion failed: %s", error.what());
            return;
        }
        std::lock_guard<std::mutex> lock(data_mutex_);
        latest_scan_ = std::move(cloud);
        latest_scan_stamp_ = msg->header.stamp;
        latest_scan_frame_ = msg->header.frame_id;
        ++scan_sequence_;
        data_cv_.notify_all();
    }

    void odomCallback(const nav_msgs::Odometry::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(data_mutex_);
        latest_odom_ = *msg;
        have_odom_ = true;
    }

    void mapChangedCallback(const std_msgs::String::ConstPtr& msg) {
        std::lock_guard<std::mutex> lock(registration_mutex_);
        map_ = PreparedMap();
        setLocalized(false);
        ROS_WARN("Active map changed to '%s'; relocalization is required", msg->data.c_str());
    }

    bool prepareMap(std::string& error) {
        std::string path;
        if (!nh_.getParam("/ground_air/active_map_pcd", path) || path.empty()) {
            error = "no active point-cloud map; call /ground_air/load_map first";
            return false;
        }
        if (map_.fine && map_.path == path) return true;

        open3d::geometry::PointCloud raw;
        if (!open3d::io::ReadPointCloud(path, raw) || raw.IsEmpty()) {
            error = "failed to read active PCD map: " + path;
            return false;
        }
        map_.coarse = downsampleWithNormals(raw, coarse_voxel_);
        map_.fine = downsampleWithNormals(raw, fine_voxel_);
        if (map_.coarse->points_.size() < static_cast<size_t>(min_scan_points_)) {
            error = "active PCD map has too few usable points";
            map_ = PreparedMap();
            return false;
        }
        map_.coarse_feature = registration::ComputeFPFHFeature(
            *map_.coarse,
            open3d::geometry::KDTreeSearchParamHybrid(coarse_voxel_ * 5.0, 100));
        map_.path = path;
        return true;
    }

    bool waitForScan(uint64_t& last_sequence, const ros::WallTime& deadline,
                     open3d::geometry::PointCloud& scan, std::string& error) {
        std::unique_lock<std::mutex> lock(data_mutex_);
        const auto remaining = deadline - ros::WallTime::now();
        if (remaining.toSec() <= 0.0 ||
            !data_cv_.wait_for(lock, std::chrono::duration<double>(remaining.toSec()),
                               [&] { return scan_sequence_ > last_sequence; })) {
            error = "timed out waiting for a fresh registered point cloud";
            return false;
        }
        if (!latest_scan_frame_.empty() && latest_scan_frame_ != odom_frame_) {
            error = "registered cloud frame is '" + latest_scan_frame_ +
                    "', expected '" + odom_frame_ + "'";
            return false;
        }
        if ((ros::Time::now() - latest_scan_stamp_).toSec() > scan_stale_timeout_) {
            error = "registered point cloud is stale";
            return false;
        }
        last_sequence = scan_sequence_;
        scan = latest_scan_;
        return true;
    }

    bool collectSubmap(uint64_t& last_sequence, const ros::WallTime& service_deadline,
                       open3d::geometry::PointCloud& submap, std::string& error) {
        ros::WallTime submap_deadline =
            ros::WallTime::now() + ros::WallDuration(submap_duration_);
        if (service_deadline < submap_deadline) submap_deadline = service_deadline;

        submap.Clear();
        int frame_count = 0;
        while (ros::ok() && ros::WallTime::now() < submap_deadline) {
            open3d::geometry::PointCloud scan;
            if (!waitForScan(last_sequence, submap_deadline, scan, error)) break;
            submap.points_.insert(submap.points_.end(), scan.points_.begin(), scan.points_.end());
            ++frame_count;
            if (frame_count >= min_submap_frames_ &&
                submap.points_.size() >= static_cast<size_t>(min_scan_points_)) {
                return true;
            }
        }
        if (frame_count < min_submap_frames_) {
            error = "received only " + std::to_string(frame_count) +
                    " fresh point-cloud frames; need at least " +
                    std::to_string(min_submap_frames_);
        } else if (submap.points_.size() < static_cast<size_t>(min_scan_points_)) {
            error = "accumulated registered point cloud has too few points";
        }
        return false;
    }

    registration::RegistrationResult globalThenIcp(
            const open3d::geometry::PointCloud& source, unsigned int seed) {
        auto source_coarse = downsampleWithNormals(source, coarse_voxel_);
        auto source_feature = registration::ComputeFPFHFeature(
            *source_coarse,
            open3d::geometry::KDTreeSearchParamHybrid(coarse_voxel_ * 5.0, 100));

        std::vector<std::reference_wrapper<const registration::CorrespondenceChecker>> checkers;
        registration::CorrespondenceCheckerBasedOnEdgeLength edge_checker(0.90);
        registration::CorrespondenceCheckerBasedOnDistance distance_checker(coarse_voxel_ * 1.5);
        checkers.push_back(edge_checker);
        checkers.push_back(distance_checker);
        const auto coarse = registration::RegistrationRANSACBasedOnFeatureMatching(
            *source_coarse, *map_.coarse, *source_feature, *map_.coarse_feature,
            true, coarse_voxel_ * 1.5,
            registration::TransformationEstimationPointToPoint(false), 4, checkers,
            registration::RANSACConvergenceCriteria(ransac_iterations_, 0.999),
            open3d::utility::optional<unsigned int>(seed));
        return icp(source, coarse.transformation_);
    }

    registration::RegistrationResult icp(
            const open3d::geometry::PointCloud& source, const Eigen::Matrix4d& guess) {
        auto source_fine = downsampleWithNormals(source, fine_voxel_);
        const auto refined = registration::RegistrationICP(
            *source_fine, *map_.fine, fine_voxel_ * 2.0, guess,
            registration::TransformationEstimationPointToPlane(),
            registration::ICPConvergenceCriteria(1e-6, 1e-6, 60));
        return registration::EvaluateRegistration(
            *source_fine, *map_.fine, fine_voxel_ * 2.0, refined.transformation_);
    }

    bool qualityGood(const registration::RegistrationResult& result) const {
        return validTransform(result.transformation_) &&
               std::isfinite(result.fitness_) && std::isfinite(result.inlier_rmse_) &&
               result.fitness_ >= min_fitness_ && result.inlier_rmse_ <= max_rmse_;
    }

    bool consistent(const Eigen::Matrix4d& a, const Eigen::Matrix4d& b) const {
        const Eigen::Matrix4d delta = a.inverse() * b;
        const double translation = delta.block<3, 1>(0, 3).norm();
        Eigen::AngleAxisd angle(delta.block<3, 3>(0, 0));
        return translation <= max_confirmation_translation_ &&
               std::abs(angle.angle()) <= max_confirmation_rotation_;
    }

    bool relocalize(ground_air_msgs::Relocalize::Request& request,
                    ground_air_msgs::Relocalize::Response& response) {
        std::unique_lock<std::mutex> registration_lock(registration_mutex_, std::try_to_lock);
        if (!registration_lock.owns_lock()) {
            response.message = "another registration is already running";
            return true;
        }
        setLocalized(false);
        std::string error;
        if (!prepareMap(error)) {
            response.message = error;
            return true;
        }

        const double timeout = request.timeout > 0.0 ? request.timeout : default_timeout_;
        const ros::WallTime deadline = ros::WallTime::now() + ros::WallDuration(timeout);
        Eigen::Matrix4d candidate = Eigen::Matrix4d::Identity();
        bool have_candidate = false;
        if (request.use_initial_guess) {
            std::lock_guard<std::mutex> lock(data_mutex_);
            if (!have_odom_) {
                response.message = "initial guess requires current odometry";
                return true;
            }
            candidate = poseMatrix(request.initial_guess.pose.pose) *
                        poseMatrix(latest_odom_.pose.pose).inverse();
            have_candidate = true;
        }

        int confirmations = 0;
        uint64_t sequence = 0;
        {
            std::lock_guard<std::mutex> lock(data_mutex_);
            sequence = scan_sequence_;
        }
        registration::RegistrationResult accepted;
        while (ros::ok() && ros::WallTime::now() < deadline) {
            open3d::geometry::PointCloud scan;
            if (!collectSubmap(sequence, deadline, scan, error)) break;

            // An unknown-pose confirmation must be an independent global solve.
            // Reusing the first candidate as an ICP seed would allow a symmetric
            // false match to confirm itself on the next accumulated submap.
            registration::RegistrationResult result = request.use_initial_guess
                ? icp(scan, candidate)
                : globalThenIcp(scan, static_cast<unsigned int>(sequence));
            if (!qualityGood(result) || (confirmations > 0 && !consistent(candidate, result.transformation_))) {
                confirmations = 0;
                have_candidate = request.use_initial_guess;
                error = "registration quality or cross-scan consistency check failed";
                continue;
            }
            candidate = result.transformation_;
            have_candidate = true;
            accepted = result;
            ++confirmations;
            if (confirmations >= required_confirmations_) break;
        }

        if (confirmations < required_confirmations_) {
            response.message = error.empty() ? "relocalization timed out" : error;
            response.fitness = 0.0;
            response.rmse = 0.0;
            return true;
        }

        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            map_to_odom_ = candidate;
            tracking_failures_ = 0;
        }
        setLocalized(true);
        publishResult(accepted);
        response.success = true;
        response.message = "global relocalization confirmed on consecutive scans";
        response.fitness = accepted.fitness_;
        response.rmse = accepted.inlier_rmse_;
        response.pose = currentMapPose();
        return true;
    }

    geometry_msgs::PoseStamped currentMapPose() {
        Eigen::Matrix4d map_to_odom;
        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            map_to_odom = map_to_odom_;
        }
        Eigen::Matrix4d odom_to_base = Eigen::Matrix4d::Identity();
        {
            std::lock_guard<std::mutex> lock(data_mutex_);
            if (have_odom_) odom_to_base = poseMatrix(latest_odom_.pose.pose);
        }
        geometry_msgs::PoseStamped pose;
        pose.header.stamp = ros::Time::now();
        pose.header.frame_id = map_frame_;
        pose.pose = matrixPose(map_to_odom * odom_to_base);
        return pose;
    }

    void publishResult(const registration::RegistrationResult& result) {
        std_msgs::Float64 fitness;
        fitness.data = result.fitness_;
        fitness_pub_.publish(fitness);
        std_msgs::Float64 rmse;
        rmse.data = result.inlier_rmse_;
        rmse_pub_.publish(rmse);
        pose_pub_.publish(currentMapPose());
        map_to_odom_pub_.publish(currentMapToOdom());
    }

    geometry_msgs::TransformStamped currentMapToOdom() {
        Eigen::Matrix4d transform;
        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            transform = map_to_odom_;
        }
        geometry_msgs::TransformStamped msg;
        msg.header.stamp = ros::Time::now();
        msg.header.frame_id = map_frame_;
        msg.child_frame_id = odom_frame_;
        msg.transform.translation.x = transform(0, 3);
        msg.transform.translation.y = transform(1, 3);
        msg.transform.translation.z = transform(2, 3);
        Eigen::Quaterniond q(transform.block<3, 3>(0, 0));
        q.normalize();
        msg.transform.rotation.x = q.x();
        msg.transform.rotation.y = q.y();
        msg.transform.rotation.z = q.z();
        msg.transform.rotation.w = q.w();
        return msg;
    }

    void setLocalized(bool value) {
        localized_.store(value);
        nh_.setParam("/ground_air/localized", value);
        std_msgs::Bool msg;
        msg.data = value;
        localized_pub_.publish(msg);
    }

    void trackingTimer(const ros::TimerEvent&) {
        if (!localized_.load()) return;
        std::unique_lock<std::mutex> registration_lock(registration_mutex_, std::try_to_lock);
        if (!registration_lock.owns_lock() || !map_.fine) return;

        std::string active_map_path;
        if (!nh_.getParam("/ground_air/active_map_pcd", active_map_path) ||
            active_map_path != map_.path) {
            map_ = PreparedMap();
            setLocalized(false);
            ROS_WARN("Active map changed; cached registration data cleared");
            return;
        }

        open3d::geometry::PointCloud scan;
        {
            std::lock_guard<std::mutex> lock(data_mutex_);
            if ((ros::Time::now() - latest_scan_stamp_).toSec() > scan_stale_timeout_) {
                registerTrackingFailure();
                return;
            }
            scan = latest_scan_;
        }
        Eigen::Matrix4d guess;
        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            guess = map_to_odom_;
        }
        const auto result = icp(scan, guess);
        if (!qualityGood(result) || !consistent(guess, result.transformation_)) {
            registerTrackingFailure();
            return;
        }
        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            map_to_odom_ = result.transformation_;
            tracking_failures_ = 0;
        }
        publishResult(result);
    }

    void registerTrackingFailure() {
        bool lost = false;
        {
            std::lock_guard<std::mutex> lock(transform_mutex_);
            lost = ++tracking_failures_ >= tracking_failure_limit_;
        }
        if (lost) {
            ROS_ERROR("Localization quality lost; navigation will be gated");
            setLocalized(false);
        }
    }

    ros::NodeHandle nh_;
    ros::NodeHandle pnh_;
    ros::Subscriber scan_sub_;
    ros::Subscriber odom_sub_;
    ros::Subscriber map_changed_sub_;
    ros::ServiceServer service_;
    ros::Publisher localized_pub_;
    ros::Publisher fitness_pub_;
    ros::Publisher rmse_pub_;
    ros::Publisher pose_pub_;
    ros::Publisher map_to_odom_pub_;
    ros::Timer tracking_timer_;

    std::mutex data_mutex_;
    std::condition_variable data_cv_;
    open3d::geometry::PointCloud latest_scan_;
    ros::Time latest_scan_stamp_;
    std::string latest_scan_frame_;
    uint64_t scan_sequence_ = 0;
    nav_msgs::Odometry latest_odom_;
    bool have_odom_ = false;

    std::mutex registration_mutex_;
    std::mutex transform_mutex_;
    Eigen::Matrix4d map_to_odom_ = Eigen::Matrix4d::Identity();
    PreparedMap map_;
    std::atomic<bool> localized_{false};
    int tracking_failures_ = 0;

    std::string scan_topic_;
    std::string odom_topic_;
    std::string map_frame_;
    std::string odom_frame_;
    std::string base_frame_;
    double coarse_voxel_;
    double fine_voxel_;
    double min_fitness_;
    double max_rmse_;
    int required_confirmations_;
    int min_scan_points_;
    int ransac_iterations_;
    double scan_stale_timeout_;
    double max_confirmation_translation_;
    double max_confirmation_rotation_;
    int tracking_failure_limit_;
    double default_timeout_;
    double submap_duration_;
    int min_submap_frames_;
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "ground_air_global_relocalizer");
    GlobalRelocalizer node;
    ros::AsyncSpinner spinner(3);
    spinner.start();
    ros::waitForShutdown();
    return 0;
}
