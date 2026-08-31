#include <ros/ros.h>
#include <ros/package.h>

#include <actionlib_msgs/GoalID.h>
#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/PoseWithCovarianceStamped.h>
#include <geometry_msgs/Twist.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/CommandTOL.h>
#include <mavros_msgs/ExtendedState.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <nav_msgs/OccupancyGrid.h>
#include <nav_msgs/Odometry.h>
#include <nav_msgs/Path.h>
#include <sensor_msgs/BatteryState.h>
#include <sensor_msgs/PointCloud2.h>
#include <sensor_msgs/point_cloud2_iterator.h>
#include <std_msgs/String.h>

#include <tf2/LinearMath/Quaternion.h>
#include <tf2/LinearMath/Matrix3x3.h>
#include <tf2_geometry_msgs/tf2_geometry_msgs.h>

#include <hv/WebSocketClient.h>
#include <nlohmann/json.hpp>
#include <yaml-cpp/yaml.h>

#include <atomic>
#include <chrono>
#include <array>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <fstream>
#include <functional>
#include <mutex>
#include <sstream>
#include <string>
#include <thread>
#include <unordered_map>
#include <vector>

#include <unistd.h>

using json = nlohmann::json;

namespace {

constexpr int CODE_OK = 0;
constexpr int CODE_MISSING_PARAM = -4;
constexpr int CODE_REJECTED_STATE = -10;
constexpr int CODE_UNHEALTHY = -13;

struct MapExportStats {
    std::size_t point_count = 0;
    double map_area = 0.0;
};

std::string nowString() {
    char buf[32];
    const std::time_t t = std::time(nullptr);
    std::tm tm{};
    localtime_r(&t, &tm);
    std::strftime(buf, sizeof(buf), "%Y-%m-%d %H:%M:%S", &tm);
    return std::string(buf);
}

template <typename T>
T yamlValue(const YAML::Node& node, const std::string& key, const T& fallback) {
    if (!node || !node[key]) return fallback;
    try {
        return node[key].as<T>();
    } catch (const std::exception& e) {
        ROS_WARN("YAML key '%s' parse failed: %s", key.c_str(), e.what());
        return fallback;
    }
}

bool fileExists(const std::string& path) {
    if (path.empty()) return false;
    std::ifstream f(path);
    return f.good();
}

std::string shellQuote(const std::string& s) {
    std::string out = "'";
    for (char c : s) {
        if (c == '\'') out += "'\\''";
        else out += c;
    }
    out += "'";
    return out;
}

bool ensureDirectory(const std::string& path) {
    if (path.empty()) return false;
    const std::string cmd = "mkdir -p " + shellQuote(path);
    return std::system(cmd.c_str()) == 0;
}

std::string runCurlUpload(const std::string& url, const std::string& path) {
    if (!fileExists(path)) {
        ROS_WARN("[upload] missing file: %s", path.c_str());
        return "";
    }

    const std::string tmp = "/tmp/spiritwing_web_upload_" + std::to_string(::getpid()) + ".txt";
    std::ostringstream cmd;
    cmd << "curl -s -X POST -F " << shellQuote("file=@" + path) << " "
        << shellQuote(url) << " > " << shellQuote(tmp) << " 2>&1";

    const int rc = std::system(cmd.str().c_str());
    std::ifstream in(tmp);
    std::stringstream buffer;
    buffer << in.rdbuf();
    std::remove(tmp.c_str());

    if (rc != 0) {
        ROS_WARN("[upload] curl failed rc=%d response=%s", rc, buffer.str().c_str());
        return "";
    }
    return buffer.str();
}

std::string runCurlUploadIfPresent(const std::string& url, const std::string& path) {
    if (path.empty()) return "";
    return runCurlUpload(url, path);
}

std::string toDownloadUrl(const std::string& base_url, const std::string& url_or_key) {
    if (url_or_key.empty()) return "";
    if (url_or_key.rfind("http://", 0) == 0 || url_or_key.rfind("https://", 0) == 0) {
        return url_or_key;
    }
    return base_url + url_or_key;
}

std::string extractUploadUrl(const std::string& response) {
    if (response.empty()) return "";
    try {
        const json j = json::parse(response);
        if (j.contains("url") && j["url"].is_string()) return j["url"].get<std::string>();
        if (j.contains("data")) {
            const auto& d = j["data"];
            if (d.is_string()) return d.get<std::string>();
            if (d.is_object()) {
                for (const char* key : {"url", "fileUrl", "file_url", "path"}) {
                    if (d.contains(key) && d[key].is_string()) return d[key].get<std::string>();
                }
            }
        }
    } catch (...) {
    }
    return "";
}

geometry_msgs::Quaternion quaternionFromYaw(double yaw) {
    tf2::Quaternion q;
    q.setRPY(0.0, 0.0, yaw);
    return tf2::toMsg(q);
}

double yawFromQuaternion(const geometry_msgs::Quaternion& q_msg) {
    tf2::Quaternion q;
    tf2::fromMsg(q_msg, q);
    double roll = 0.0, pitch = 0.0, yaw = 0.0;
    tf2::Matrix3x3(q).getRPY(roll, pitch, yaw);
    return yaw;
}

}  // namespace

class SpiritWingWebNode {
public:
    explicit SpiritWingWebNode(ros::NodeHandle nh) : nh_(std::move(nh)) {}

    void start() {
        loadConfig();
        setupRos();
        setupWebSocket();

        status_timer_ = nh_.createTimer(ros::Duration(1.0), &SpiritWingWebNode::onStatusTimer, this);
        manual_timer_ = nh_.createTimer(
            ros::Duration(1.0 / std::max(1.0, cfg_.manual_republish_hz)),
            &SpiritWingWebNode::onManualTimer, this);
        realtime_cloud_timer_ = nh_.createTimer(
            ros::Duration(std::max(1.0, cfg_.realtime_cloud_period_s)),
            &SpiritWingWebNode::onRealtimeCloudTimer, this);

        const std::string ws_url = cfg_.url + cfg_.sn;
        ROS_INFO("[spiritwing_web] connecting: %s", ws_url.c_str());
        ws_.open(ws_url.c_str());
    }

private:
    struct Config {
        std::string params_file;
        std::string url = "ws://10.10.11.50/showroom-api/ws?deviceId=";
        std::string sn = "SPIRITWING_LUKONG_SN";
        std::string area_id = "123";
        std::string file_upload_url;
        std::string file_download_url;
        std::string command_backend = "json_placeholder";
        std::string navigation_backend = "patrol_points";

        std::string mavros_state_topic = "/mavros/state";
        std::string mavros_extended_topic = "/mavros/extended_state";
        std::string battery_topic = "/mavros/battery";
        std::string odom_topic = "/Odometry";
        std::string fallback_odom_topic = "/mavros/local_position/odom";
        std::string initialpose_topic = "/initialpose";
        std::string patrol_points_topic = "/spiritwing/patrol_points";
        std::string move_base_goal_topic = "/move_base_simple/goal";
        std::string move_base_cancel_topic = "/move_base/cancel";
        std::string patrol_state_text_topic = "/spiritwing/patrol_state_text_placeholder";
        std::string command_text_topic = "/spiritwing/command_json_placeholder";
        std::string pointcloud_topic = "/livox/lidar";
        std::string map_topic = "/map";
        std::string mavros_manual_vel_topic = "/mavros/setpoint_velocity/cmd_vel_unstamped";
        std::string cmd_vel_topic = "/cmd_vel";

        std::string arming_srv = "/mavros/cmd/arming";
        std::string set_mode_srv = "/mavros/set_mode";
        std::string takeoff_srv = "/mavros/cmd/takeoff";
        std::string land_srv = "/mavros/cmd/land";

        std::string task_frame_id = "map";
        std::string move_base_goal_frame_id = "map";
        std::string initialpose_frame_id = "map";

        double default_takeoff_altitude = 1.0;
        double manual_speed = 0.5;
        double manual_vertical_speed = 0.3;
        double manual_yaw_rate = 0.5;
        double manual_timeout_s = 2.0;
        double manual_republish_hz = 30.0;
        bool set_mode_before_mavros_control = false;
        std::string mavros_control_mode = "OFFBOARD";
        bool enable_realtime_cloud = true;
        double realtime_cloud_period_s = 10.0;
        double realtime_cloud_stale_timeout_s = 3.0;
        std::size_t realtime_cloud_max_points = 8000;
        double navigation_goal_tolerance = 0.6;
        double navigation_goal_min_time_s = 1.0;

        std::string maps_dir;
        std::string pcd_path;
        std::string pgm_path;
        std::string yaml_path;
        std::string pose_path;

        std::string sensor_script;
        std::string mapping_script;
        std::string mission_script;
    } cfg_;

    struct GoalPoint {
        double x = 0.0;
        double y = 0.0;
        double z = 0.0;
        geometry_msgs::Quaternion q = quaternionFromYaw(0.0);
        int timeout = 0;
    };

    ros::NodeHandle nh_;
    hv::WebSocketClient ws_;
    std::unordered_map<std::string, std::function<void(const json&)>> handlers_;

    ros::Subscriber sub_mavros_state_;
    ros::Subscriber sub_mavros_extended_;
    ros::Subscriber sub_battery_;
    ros::Subscriber sub_odom_;
    ros::Subscriber sub_fallback_odom_;
    ros::Subscriber sub_patrol_state_text_;
    ros::Subscriber sub_pointcloud_;
    ros::Subscriber sub_map_;

    ros::Publisher pub_patrol_points_;
    ros::Publisher pub_move_base_goal_;
    ros::Publisher pub_move_base_cancel_;
    ros::Publisher pub_initialpose_;
    ros::Publisher pub_command_text_;
    ros::Publisher pub_mavros_manual_vel_;
    ros::Publisher pub_cmd_vel_;

    ros::ServiceClient cli_arming_;
    ros::ServiceClient cli_set_mode_;
    ros::ServiceClient cli_takeoff_;
    ros::ServiceClient cli_land_;

    ros::Timer status_timer_;
    ros::Timer manual_timer_;
    ros::Timer realtime_cloud_timer_;

    std::mutex mutex_;
    std::vector<GoalPoint> goals_;
    std::string active_area_id_;
    std::string current_map_id_;
    std::string robot_state_ = "INITIALIZING";
    bool mapping_active_ = false;
    bool navigating_active_ = false;
    bool manual_active_ = false;
    bool relocalized_ = false;
    bool move_base_sequence_active_ = false;
    std::size_t active_goal_index_ = 0;
    ros::Time last_odom_time_;
    ros::Time last_manual_time_;
    ros::Time active_goal_sent_time_;
    nav_msgs::Odometry latest_odom_;
    nav_msgs::OccupancyGrid latest_map_;
    mavros_msgs::State latest_mavros_state_;
    mavros_msgs::ExtendedState latest_extended_state_;
    sensor_msgs::BatteryState latest_battery_;
    geometry_msgs::Twist manual_twist_;
    std::vector<std::array<float, 3>> latest_point_cloud_;
    ros::Time last_map_time_;
    ros::Time last_point_cloud_time_;
    std::string generated_pgm_path_;
    std::string generated_yaml_path_;
    std::string generated_upload_yaml_path_;
    std::string generated_pcd_path_;
    std::string generated_pose_path_;
    MapExportStats last_map_stats_;
    std::atomic<bool> realtime_cloud_uploading_{false};

    void loadConfig() {
        std::string params_file;
        nh_.param<std::string>("params_file", params_file, "");
        if (params_file.empty()) {
            const std::string pkg_path = ros::package::getPath("spiritwing_web");
            params_file = pkg_path + "/config/params.yaml";
        }
        cfg_.params_file = params_file;
        active_area_id_ = cfg_.area_id;

        YAML::Node root = YAML::LoadFile(params_file);
        const YAML::Node web = root["web_node"];
        cfg_.url = yamlValue<std::string>(web, "url", cfg_.url);
        cfg_.sn = yamlValue<std::string>(web, "sn", cfg_.sn);
        cfg_.area_id = yamlValue<std::string>(web, "area_id", cfg_.area_id);
        cfg_.file_upload_url = yamlValue<std::string>(web, "URL_FILE_UPLOAD", cfg_.file_upload_url);
        cfg_.file_download_url = yamlValue<std::string>(web, "URL_FILE_DOWNLOAD", cfg_.file_download_url);
        active_area_id_ = cfg_.area_id;

        const YAML::Node sw = root["spiritwing_node"];
        cfg_.command_backend = yamlValue<std::string>(sw, "command_backend", cfg_.command_backend);
        cfg_.navigation_backend = yamlValue<std::string>(sw, "navigation_backend", cfg_.navigation_backend);

        const YAML::Node topics = sw["topics"];
        cfg_.mavros_state_topic = yamlValue<std::string>(topics, "mavros_state", cfg_.mavros_state_topic);
        cfg_.mavros_extended_topic = yamlValue<std::string>(topics, "mavros_extended", cfg_.mavros_extended_topic);
        cfg_.battery_topic = yamlValue<std::string>(topics, "mavros_battery", cfg_.battery_topic);
        cfg_.odom_topic = yamlValue<std::string>(topics, "odom", cfg_.odom_topic);
        cfg_.fallback_odom_topic = yamlValue<std::string>(topics, "fallback_odom", cfg_.fallback_odom_topic);
        cfg_.initialpose_topic = yamlValue<std::string>(topics, "initialpose", cfg_.initialpose_topic);
        cfg_.patrol_points_topic = yamlValue<std::string>(topics, "patrol_points", cfg_.patrol_points_topic);
        cfg_.move_base_goal_topic = yamlValue<std::string>(topics, "move_base_goal", cfg_.move_base_goal_topic);
        cfg_.move_base_cancel_topic = yamlValue<std::string>(topics, "move_base_cancel", cfg_.move_base_cancel_topic);
        cfg_.patrol_state_text_topic = yamlValue<std::string>(topics, "patrol_state_text", cfg_.patrol_state_text_topic);
        cfg_.command_text_topic = yamlValue<std::string>(topics, "command_text", cfg_.command_text_topic);
        cfg_.pointcloud_topic = yamlValue<std::string>(topics, "pointcloud", cfg_.pointcloud_topic);
        cfg_.map_topic = yamlValue<std::string>(topics, "map", cfg_.map_topic);
        cfg_.mavros_manual_vel_topic = yamlValue<std::string>(topics, "mavros_manual_vel", cfg_.mavros_manual_vel_topic);
        cfg_.cmd_vel_topic = yamlValue<std::string>(topics, "cmd_vel", cfg_.cmd_vel_topic);

        const YAML::Node services = sw["services"];
        cfg_.arming_srv = yamlValue<std::string>(services, "mavros_arming", cfg_.arming_srv);
        cfg_.set_mode_srv = yamlValue<std::string>(services, "mavros_set_mode", cfg_.set_mode_srv);
        cfg_.takeoff_srv = yamlValue<std::string>(services, "mavros_takeoff", cfg_.takeoff_srv);
        cfg_.land_srv = yamlValue<std::string>(services, "mavros_land", cfg_.land_srv);

        const YAML::Node frames = sw["frames"];
        cfg_.task_frame_id = yamlValue<std::string>(frames, "task_frame_id", cfg_.task_frame_id);
        cfg_.move_base_goal_frame_id = yamlValue<std::string>(frames, "move_base_goal_frame_id", cfg_.move_base_goal_frame_id);
        cfg_.initialpose_frame_id = yamlValue<std::string>(frames, "initialpose_frame_id", cfg_.initialpose_frame_id);

        const YAML::Node control = sw["control"];
        cfg_.default_takeoff_altitude = yamlValue<double>(control, "default_takeoff_altitude", cfg_.default_takeoff_altitude);
        cfg_.manual_speed = yamlValue<double>(control, "manual_speed", cfg_.manual_speed);
        cfg_.manual_vertical_speed = yamlValue<double>(control, "manual_vertical_speed", cfg_.manual_vertical_speed);
        cfg_.manual_yaw_rate = yamlValue<double>(control, "manual_yaw_rate", cfg_.manual_yaw_rate);
        cfg_.manual_timeout_s = yamlValue<double>(control, "manual_timeout_s", cfg_.manual_timeout_s);
        cfg_.manual_republish_hz = yamlValue<double>(control, "republish_manual_hz", cfg_.manual_republish_hz);
        cfg_.set_mode_before_mavros_control = yamlValue<bool>(control, "set_mode_before_mavros_control", cfg_.set_mode_before_mavros_control);
        cfg_.mavros_control_mode = yamlValue<std::string>(control, "mavros_control_mode", cfg_.mavros_control_mode);
        cfg_.enable_realtime_cloud = yamlValue<bool>(control, "enable_realtime_cloud", cfg_.enable_realtime_cloud);
        cfg_.realtime_cloud_period_s = yamlValue<double>(control, "realtime_cloud_period_s", cfg_.realtime_cloud_period_s);
        cfg_.realtime_cloud_stale_timeout_s = yamlValue<double>(control, "realtime_cloud_stale_timeout_s", cfg_.realtime_cloud_stale_timeout_s);
        cfg_.realtime_cloud_max_points = yamlValue<std::size_t>(control, "realtime_cloud_max_points", cfg_.realtime_cloud_max_points);
        cfg_.navigation_goal_tolerance = yamlValue<double>(control, "navigation_goal_tolerance", cfg_.navigation_goal_tolerance);
        cfg_.navigation_goal_min_time_s = yamlValue<double>(control, "navigation_goal_min_time_s", cfg_.navigation_goal_min_time_s);

        const YAML::Node maps = sw["maps"];
        cfg_.maps_dir = yamlValue<std::string>(maps, "maps_dir", cfg_.maps_dir);
        cfg_.pcd_path = yamlValue<std::string>(maps, "pcd_path", cfg_.pcd_path);
        cfg_.pgm_path = yamlValue<std::string>(maps, "pgm_path", cfg_.pgm_path);
        cfg_.yaml_path = yamlValue<std::string>(maps, "yaml_path", cfg_.yaml_path);
        cfg_.pose_path = yamlValue<std::string>(maps, "pose_path", cfg_.pose_path);

        const YAML::Node scripts = sw["scripts"];
        cfg_.sensor_script = yamlValue<std::string>(scripts, "sensor", cfg_.sensor_script);
        cfg_.mapping_script = yamlValue<std::string>(scripts, "mapping", cfg_.mapping_script);
        cfg_.mission_script = yamlValue<std::string>(scripts, "mission", cfg_.mission_script);

        ROS_INFO("[spiritwing_web] params: %s", cfg_.params_file.c_str());
        ROS_INFO("[spiritwing_web] command_backend=%s navigation_backend=%s patrol_points=%s move_base_goal=%s command_text=%s",
                 cfg_.command_backend.c_str(), cfg_.navigation_backend.c_str(),
                 cfg_.patrol_points_topic.c_str(), cfg_.move_base_goal_topic.c_str(),
                 cfg_.command_text_topic.c_str());
    }

    void setupRos() {
        sub_mavros_state_ = nh_.subscribe(cfg_.mavros_state_topic, 10, &SpiritWingWebNode::onMavrosState, this);
        sub_mavros_extended_ = nh_.subscribe(cfg_.mavros_extended_topic, 10, &SpiritWingWebNode::onExtendedState, this);
        sub_battery_ = nh_.subscribe(cfg_.battery_topic, 10, &SpiritWingWebNode::onBattery, this);
        sub_odom_ = nh_.subscribe(cfg_.odom_topic, 20, &SpiritWingWebNode::onOdom, this);
        if (cfg_.fallback_odom_topic != cfg_.odom_topic) {
            sub_fallback_odom_ = nh_.subscribe(cfg_.fallback_odom_topic, 20, &SpiritWingWebNode::onOdom, this);
        }
        sub_patrol_state_text_ = nh_.subscribe(cfg_.patrol_state_text_topic, 10, &SpiritWingWebNode::onPatrolStateText, this);
        sub_pointcloud_ = nh_.subscribe(cfg_.pointcloud_topic, 1, &SpiritWingWebNode::onPointCloud, this);
        sub_map_ = nh_.subscribe(cfg_.map_topic, 1, &SpiritWingWebNode::onMap, this);

        pub_patrol_points_ = nh_.advertise<nav_msgs::Path>(cfg_.patrol_points_topic, 1, true);
        pub_move_base_goal_ = nh_.advertise<geometry_msgs::PoseStamped>(cfg_.move_base_goal_topic, 1);
        pub_move_base_cancel_ = nh_.advertise<actionlib_msgs::GoalID>(cfg_.move_base_cancel_topic, 1);
        pub_initialpose_ = nh_.advertise<geometry_msgs::PoseWithCovarianceStamped>(cfg_.initialpose_topic, 1);
        pub_command_text_ = nh_.advertise<std_msgs::String>(cfg_.command_text_topic, 10);
        pub_mavros_manual_vel_ = nh_.advertise<geometry_msgs::Twist>(cfg_.mavros_manual_vel_topic, 10);
        pub_cmd_vel_ = nh_.advertise<geometry_msgs::Twist>(cfg_.cmd_vel_topic, 10);

        cli_arming_ = nh_.serviceClient<mavros_msgs::CommandBool>(cfg_.arming_srv);
        cli_set_mode_ = nh_.serviceClient<mavros_msgs::SetMode>(cfg_.set_mode_srv);
        cli_takeoff_ = nh_.serviceClient<mavros_msgs::CommandTOL>(cfg_.takeoff_srv);
        cli_land_ = nh_.serviceClient<mavros_msgs::CommandTOL>(cfg_.land_srv);
    }

    void setupWebSocket() {
        initHandlers();

        ws_.onopen = []() {
            ROS_INFO("[spiritwing_web] WebSocket connected");
        };
        ws_.onclose = []() {
            ROS_WARN("[spiritwing_web] WebSocket closed");
        };
        ws_.onmessage = [this](const std::string& msg) {
            std::thread([this, msg]() {
                try {
                    const json j = json::parse(msg);
                    const std::string type = j.value("type", "");
                    if (j.contains("area_id") && j["area_id"].is_string()) {
                        std::lock_guard<std::mutex> lk(mutex_);
                        active_area_id_ = j["area_id"].get<std::string>();
                    }
                    const auto it = handlers_.find(type);
                    if (it != handlers_.end()) {
                        it->second(j);
                    } else if (!type.empty()) {
                        ROS_DEBUG("[spiritwing_web] ignore unknown message type=%s", type.c_str());
                    }
                } catch (const std::exception& e) {
                    ROS_WARN("[spiritwing_web] bad websocket message: %s raw=%s", e.what(), msg.c_str());
                }
            }).detach();
        };

        reconn_setting_t reconn;
        reconn_setting_init(&reconn);
        reconn.min_delay = 1000;
        reconn.max_delay = 10000;
        reconn.delay_policy = 2;
        ws_.setReconnect(&reconn);
    }

    void initHandlers() {
        handlers_["server_heartbeat"] = [](const json&) {};
        handlers_["get_current_map_id_down"] = [this](const json& j) { handleGetCurrentMapId(j); };
        handlers_["get_current_map_down"] = [this](const json& j) { handleGetCurrentMap(j); };
        handlers_["set_current_map_down"] = [this](const json& j) { handleSetCurrentMap(j); };
        handlers_["relocalize_pose_down"] = [this](const json& j) { handleRelocalize(j); };
        handlers_["multi_goal_down"] = [this](const json& j) { handleMultiGoal(j); };
        handlers_["navigation_start_down"] = [this](const json& j) { handleNavigationStart(j); };
        handlers_["navigation_pause_down"] = [this](const json& j) { handleNavigationPause(j); };
        handlers_["navigation_resume_down"] = [this](const json& j) { handleNavigationResume(j); };
        handlers_["navigation_stop_down"] = [this](const json& j) { handleNavigationStop(j); };
        handlers_["manual_control_down"] = [this](const json& j) { handleManualControl(j); };
        handlers_["set_max_speed_down"] = [this](const json& j) { handleSetMaxSpeed(j); };
        handlers_["slam_start_down"] = [this](const json& j) { handleSlamStart(j); };
        handlers_["slam_stop_down"] = [this](const json& j) { handleSlamStop(j); };

        // UAV-specific extensions. The public protocol may or may not send these.
        handlers_["takeoff_down"] = [this](const json& j) { handleTakeoff(j); };
        handlers_["land_down"] = [this](const json& j) { handleLand(j); };
        handlers_["emergency_stop_down"] = [this](const json& j) { handleEmergencyStop(j); };
    }

    void sendJson(const json& j) {
        if (!ws_.isConnected()) {
            ROS_WARN_THROTTLE(2.0, "[spiritwing_web] websocket not connected, drop: %s", j.dump().c_str());
            return;
        }
        ws_.send(j.dump());
    }

    json baseResponse(const std::string& type) {
        std::lock_guard<std::mutex> lk(mutex_);
        return {
            {"type", type},
            {"forward", false},
            {"sn", cfg_.sn},
            {"area_id", active_area_id_}
        };
    }

    void updateAreaAndMap(const json& j) {
        std::lock_guard<std::mutex> lk(mutex_);
        if (j.contains("area_id") && j["area_id"].is_string()) active_area_id_ = j["area_id"].get<std::string>();
        if (j.contains("map_id") && j["map_id"].is_string()) current_map_id_ = j["map_id"].get<std::string>();
    }

    void handleGetCurrentMapId(const json&) {
        auto r = baseResponse("get_current_map_id_up");
        {
            std::lock_guard<std::mutex> lk(mutex_);
            r["map_id"] = current_map_id_;
        }
        sendJson(r);
    }

    void handleGetCurrentMap(const json&) {
        auto r = baseResponse("get_current_map_up");
        r["url_pcd"] = "";
        r["url_txt"] = "";
        r["url_pgm"] = "";
        r["url_yaml"] = "";
        sendJson(r);
    }

    void handleSetCurrentMap(const json& j) {
        updateAreaAndMap(j);
        auto r = baseResponse("set_current_map_up");
        r["code"] = CODE_OK;
        r["reason"] = "map id accepted; SpiritWing historical map load API is not available in current documents";
        sendJson(r);

        auto done = baseResponse("set_current_map_complete_up");
        {
            std::lock_guard<std::mutex> lk(mutex_);
            done["map_id"] = current_map_id_;
        }
        sendJson(done);
    }

    void handleRelocalize(const json& j) {
        updateAreaAndMap(j);
        auto r = baseResponse("relocalize_pose_up");
        try {
            if (!j.contains("pose")) {
                r["code"] = CODE_MISSING_PARAM;
                r["reason"] = "missing field: pose";
                sendJson(r);
                return;
            }
            const auto& pose = j["pose"];
            geometry_msgs::PoseWithCovarianceStamped msg;
            msg.header.stamp = ros::Time::now();
            msg.header.frame_id = cfg_.initialpose_frame_id;
            msg.pose.pose.position.x = pose["position"].value("x", 0.0);
            msg.pose.pose.position.y = pose["position"].value("y", 0.0);
            msg.pose.pose.position.z = pose["position"].value("z", 0.0);

            const auto& o = pose["orientation"];
            geometry_msgs::Quaternion q;
            q.x = o.value("x", 0.0);
            q.y = o.value("y", 0.0);
            q.z = o.value("z", 0.0);
            q.w = o.value("w", 0.0);
            if (std::abs(q.x) + std::abs(q.y) + std::abs(q.z) + std::abs(q.w) < 1e-6) {
                q = quaternionFromYaw(o.value("yaw", 0.0));
            }
            msg.pose.pose.orientation = q;
            msg.pose.covariance[0] = 0.25;
            msg.pose.covariance[7] = 0.25;
            msg.pose.covariance[35] = 0.0685;
            pub_initialpose_.publish(msg);

            {
                std::lock_guard<std::mutex> lk(mutex_);
                relocalized_ = true;
                robot_state_ = "LOCALIZING";
            }
            r["code"] = CODE_OK;
            sendJson(r);
        } catch (const std::exception& e) {
            r["code"] = CODE_MISSING_PARAM;
            r["reason"] = e.what();
            sendJson(r);
        }
    }

    void handleMultiGoal(const json& j) {
        updateAreaAndMap(j);
        auto r = baseResponse("multi_goal_up");
        try {
            if (!j.contains("target_points") || !j["target_points"].is_array()) {
                r["code"] = CODE_MISSING_PARAM;
                r["reason"] = "missing array: target_points";
                sendJson(r);
                return;
            }
            std::vector<GoalPoint> parsed;
            for (const auto& p : j["target_points"]) {
                GoalPoint g;
                g.x = p.value("x", 0.0);
                g.y = p.value("y", 0.0);
                g.z = p.value("z", cfg_.default_takeoff_altitude);
                g.timeout = p.value("timeout", 0);
                if (p.contains("orientation")) {
                    const auto& o = p["orientation"];
                    geometry_msgs::Quaternion q;
                    q.x = o.value("x", 0.0);
                    q.y = o.value("y", 0.0);
                    q.z = o.value("z", 0.0);
                    q.w = o.value("w", 0.0);
                    if (std::abs(q.x) + std::abs(q.y) + std::abs(q.z) + std::abs(q.w) < 1e-6) {
                        q = quaternionFromYaw(o.value("yaw", 0.0));
                    }
                    g.q = q;
                }
                parsed.push_back(g);
            }
            {
                std::lock_guard<std::mutex> lk(mutex_);
                goals_ = parsed;
            }
            r["code"] = CODE_OK;
            r["map_id"] = j.value("map_id", current_map_id_);
            r["goal_count"] = parsed.size();
            sendJson(r);
        } catch (const std::exception& e) {
            r["code"] = CODE_MISSING_PARAM;
            r["reason"] = e.what();
            sendJson(r);
        }
    }

    void handleNavigationStart(const json& j) {
        updateAreaAndMap(j);
        auto r = baseResponse("navigation_start_up");

        nav_msgs::Path path;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            if (goals_.empty()) {
                r["code"] = CODE_REJECTED_STATE;
                r["reason"] = "no cached target_points; send multi_goal_down first";
                sendJson(r);
                return;
            }
            path.header.stamp = ros::Time::now();
            path.header.frame_id = cfg_.task_frame_id;
            for (const auto& g : goals_) {
                geometry_msgs::PoseStamped ps;
                ps.header = path.header;
                ps.pose.position.x = g.x;
                ps.pose.position.y = g.y;
                ps.pose.position.z = g.z;
                ps.pose.orientation = g.q;
                path.poses.push_back(ps);
            }
            navigating_active_ = true;
            manual_active_ = false;
            active_goal_index_ = 0;
            move_base_sequence_active_ = cfg_.navigation_backend == "move_base_simple" || cfg_.navigation_backend == "both";
            robot_state_ = "NAVIGATING";
        }

        runScriptAsync(cfg_.mission_script, "mission");
        publishNavigationGoals(path);
        publishCommandJson("navigation_start", {
            {"goal_count", path.poses.size()},
            {"frame_id", cfg_.task_frame_id},
            {"navigation_backend", cfg_.navigation_backend}
        });
        r["code"] = CODE_OK;
        r["goal_count"] = path.poses.size();
        sendJson(r);
    }

    void handleNavigationPause(const json&) {
        cancelNavigationGoal("navigation_pause");
        publishHover("navigation_pause");
        {
            std::lock_guard<std::mutex> lk(mutex_);
            navigating_active_ = false;
            move_base_sequence_active_ = false;
            robot_state_ = "NAVIGATING_PAUSED";
        }
        auto r = baseResponse("navigation_pause_up");
        r["code"] = CODE_OK;
        sendJson(r);
    }

    void handleNavigationResume(const json&) {
        handleNavigationStart(json::object());
        auto r = baseResponse("navigation_resume_up");
        r["code"] = CODE_OK;
        sendJson(r);
    }

    void handleNavigationStop(const json&) {
        cancelNavigationGoal("navigation_stop");
        publishHover("navigation_stop");
        {
            std::lock_guard<std::mutex> lk(mutex_);
            navigating_active_ = false;
            manual_active_ = false;
            move_base_sequence_active_ = false;
            robot_state_ = "IDLE";
        }
        auto r = baseResponse("navigation_stop_up");
        r["code"] = CODE_OK;
        sendJson(r);
    }

    void handleManualControl(const json& j) {
        updateAreaAndMap(j);
        auto r = baseResponse("manual_control_up");
        const std::string action = j.value("action", "");
        double speed = 1.0;
        if (j.contains("parameters") && j["parameters"].is_object()) {
            speed = j["parameters"].value("speed", 1.0);
        }
        speed = std::max(0.0, std::min(1.0, speed));

        geometry_msgs::Twist twist;
        if (action == "forward") twist.linear.x = cfg_.manual_speed * speed;
        else if (action == "backward") twist.linear.x = -cfg_.manual_speed * speed;
        else if (action == "turn_left") twist.angular.z = cfg_.manual_yaw_rate * speed;
        else if (action == "turn_right") twist.angular.z = -cfg_.manual_yaw_rate * speed;
        else if (action == "stand") twist.linear.z = cfg_.manual_vertical_speed * speed;
        else if (action == "down") twist.linear.z = -cfg_.manual_vertical_speed * speed;
        else if (action == "stop") {
            publishHover("manual_stop");
            {
                std::lock_guard<std::mutex> lk(mutex_);
                manual_active_ = false;
                robot_state_ = "IDLE";
            }
            r["code"] = CODE_OK;
            r["action"] = action;
            sendJson(r);
            return;
        } else {
            r["code"] = CODE_MISSING_PARAM;
            r["reason"] = "unknown action: " + action;
            r["action"] = action;
            sendJson(r);
            return;
        }

        {
            std::lock_guard<std::mutex> lk(mutex_);
            manual_twist_ = twist;
            manual_active_ = true;
            navigating_active_ = false;
            robot_state_ = "MANUAL_CONTROL";
            last_manual_time_ = ros::Time::now();
        }
        publishManualTwist(twist, action);
        r["code"] = CODE_OK;
        r["action"] = action;
        r["vx"] = twist.linear.x;
        r["vy"] = twist.linear.y;
        r["vz"] = twist.linear.z;
        r["yaw_rate"] = twist.angular.z;
        sendJson(r);
    }

    void handleSetMaxSpeed(const json&) {
        auto r = baseResponse("set_max_speed_up");
        r["code"] = CODE_OK;
        r["reason"] = "accepted but not applied; SpiritWing speed parameter API is not available in current documents";
        sendJson(r);
    }

    void handleSlamStart(const json& j) {
        updateAreaAndMap(j);
        {
            std::lock_guard<std::mutex> lk(mutex_);
            mapping_active_ = true;
            robot_state_ = "MAPPING";
        }
        runScriptAsync(cfg_.mapping_script, "mapping");
        publishCommandJson("slam_start", {{"map_id", j.value("map_id", "")}});
        auto r = baseResponse("slam_start_up");
        r["code"] = CODE_OK;
        sendJson(r);
    }

    void handleSlamStop(const json&) {
        {
            std::lock_guard<std::mutex> lk(mutex_);
            mapping_active_ = false;
            robot_state_ = "IDLE";
        }
        publishCommandJson("slam_stop", {});
        auto r = baseResponse("slam_stop_up");
        r["code"] = CODE_OK;
        sendJson(r);
        saveLatestMapFromOccupancyGrid();
        uploadMapFiles();
    }

    void handleTakeoff(const json& j) {
        auto r = baseResponse("takeoff_up");
        const double alt = j.value("altitude", cfg_.default_takeoff_altitude);
        const bool ok = publishTakeoff(alt);
        r["code"] = ok ? CODE_OK : CODE_UNHEALTHY;
        r["altitude"] = alt;
        if (!ok) r["reason"] = "takeoff command failed";
        sendJson(r);
    }

    void handleLand(const json&) {
        auto r = baseResponse("land_up");
        const bool ok = publishLand();
        r["code"] = ok ? CODE_OK : CODE_UNHEALTHY;
        if (!ok) r["reason"] = "land command failed";
        sendJson(r);
    }

    void handleEmergencyStop(const json&) {
        publishHover("emergency_stop");
        publishCommandJson("emergency_stop", {});
        {
            std::lock_guard<std::mutex> lk(mutex_);
            navigating_active_ = false;
            manual_active_ = false;
            robot_state_ = "FAULT";
        }
        auto r = baseResponse("emergency_stop_up");
        r["code"] = CODE_OK;
        sendJson(r);
    }

    bool publishTakeoff(double altitude) {
        if (cfg_.command_backend == "mavros") {
            if (cfg_.set_mode_before_mavros_control) setMavrosMode(cfg_.mavros_control_mode);
            mavros_msgs::CommandBool arm;
            arm.request.value = true;
            cli_arming_.call(arm);

            mavros_msgs::CommandTOL srv;
            srv.request.altitude = altitude;
            srv.request.latitude = 0.0;
            srv.request.longitude = 0.0;
            srv.request.min_pitch = 0.0;
            srv.request.yaw = currentYaw();
            const bool ok = cli_takeoff_.call(srv) && srv.response.success;
            ROS_INFO("[spiritwing_web] mavros takeoff altitude=%.2f ok=%s", altitude, ok ? "true" : "false");
            return ok;
        }
        publishCommandJson("takeoff", {
            {"control_state", "COMMAND_CONTROL"},
            {"mode", "Init_Pos_Hover"},
            {"altitude", altitude}
        });
        return true;
    }

    bool publishLand() {
        if (cfg_.command_backend == "mavros") {
            mavros_msgs::CommandTOL srv;
            srv.request.yaw = currentYaw();
            const bool ok = cli_land_.call(srv) && srv.response.success;
            ROS_INFO("[spiritwing_web] mavros land ok=%s", ok ? "true" : "false");
            return ok;
        }
        publishCommandJson("land", {{"uav_command", "Land"}});
        return true;
    }

    void publishHover(const std::string& reason) {
        geometry_msgs::Twist zero;
        pub_mavros_manual_vel_.publish(zero);
        pub_cmd_vel_.publish(zero);
        publishCommandJson("hover", {{"mode", "Current_Pos_Hover"}, {"reason", reason}});
    }

    void cancelNavigationGoal(const std::string& reason) {
        if (cfg_.navigation_backend != "move_base_simple" && cfg_.navigation_backend != "both") return;
        actionlib_msgs::GoalID cancel;
        cancel.stamp = ros::Time(0);
        cancel.id = "";
        pub_move_base_cancel_.publish(cancel);
        geometry_msgs::Twist zero;
        for (int i = 0; i < 3; ++i) {
            pub_cmd_vel_.publish(zero);
            pub_mavros_manual_vel_.publish(zero);
        }
        ROS_INFO("[spiritwing_web] cancel move_base goal: topic=%s reason=%s",
                 cfg_.move_base_cancel_topic.c_str(), reason.c_str());
    }

    void publishManualTwist(const geometry_msgs::Twist& twist, const std::string& action) {
        if (cfg_.command_backend == "mavros") {
            pub_mavros_manual_vel_.publish(twist);
            return;
        }
        if (cfg_.command_backend == "cmd_vel") {
            pub_cmd_vel_.publish(twist);
            return;
        }
        publishCommandJson("manual_control", {
            {"action", action},
            {"frame_id", "base_link"},
            {"velocity", {
                {"x", twist.linear.x},
                {"y", twist.linear.y},
                {"z", twist.linear.z},
                {"yaw_rate", twist.angular.z}
            }}
        });
    }

    void publishNavigationGoals(const nav_msgs::Path& path) {
        if (cfg_.navigation_backend == "patrol_points" || cfg_.navigation_backend == "both") {
            pub_patrol_points_.publish(path);
            ROS_INFO("[spiritwing_web] publish navigation path: topic=%s goals=%zu frame=%s",
                     cfg_.patrol_points_topic.c_str(), path.poses.size(), path.header.frame_id.c_str());
        }
        if ((cfg_.navigation_backend == "move_base_simple" || cfg_.navigation_backend == "both") && !path.poses.empty()) {
            publishMoveBaseGoal(path.poses.front(), 0, path.poses.size());
        }
    }

    void publishMoveBaseGoal(geometry_msgs::PoseStamped goal, std::size_t index, std::size_t total) {
        goal.header.stamp = ros::Time::now();
        goal.header.frame_id = cfg_.move_base_goal_frame_id;
        if (std::abs(goal.pose.orientation.x) + std::abs(goal.pose.orientation.y) +
            std::abs(goal.pose.orientation.z) + std::abs(goal.pose.orientation.w) < 1e-6) {
            goal.pose.orientation.w = 1.0;
        }
        {
            std::lock_guard<std::mutex> lk(mutex_);
            active_goal_sent_time_ = ros::Time::now();
        }
        pub_move_base_goal_.publish(goal);
        ROS_INFO("[spiritwing_web] publish move_base goal: topic=%s index=%zu/%zu pos=(%.3f, %.3f, %.3f) frame=%s",
                 cfg_.move_base_goal_topic.c_str(), index + 1, total, goal.pose.position.x,
                 goal.pose.position.y, goal.pose.position.z, goal.header.frame_id.c_str());
    }

    void publishCommandJson(const std::string& command, json payload) {
        payload["source"] = "spiritwing_web";
        payload["command"] = command;
        payload["time"] = nowString();
        payload["sn"] = cfg_.sn;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            payload["area_id"] = active_area_id_;
            payload["map_id"] = current_map_id_;
        }

        std_msgs::String msg;
        msg.data = payload.dump();
        pub_command_text_.publish(msg);
        ROS_INFO("[spiritwing_web] command placeholder: %s", msg.data.c_str());
    }

    bool setMavrosMode(const std::string& mode) {
        mavros_msgs::SetMode srv;
        srv.request.custom_mode = mode;
        const bool ok = cli_set_mode_.call(srv) && srv.response.mode_sent;
        ROS_INFO("[spiritwing_web] set mode %s ok=%s", mode.c_str(), ok ? "true" : "false");
        return ok;
    }

    double currentYaw() {
        std::lock_guard<std::mutex> lk(mutex_);
        if (last_odom_time_.isZero()) return 0.0;
        return yawFromQuaternion(latest_odom_.pose.pose.orientation);
    }

    bool writeGridPcd(const nav_msgs::OccupancyGrid& map, const std::string& path, std::size_t& point_count) {
        std::vector<std::array<float, 3>> points;
        points.reserve(map.data.size());
        const double resolution = map.info.resolution;
        const double origin_x = map.info.origin.position.x;
        const double origin_y = map.info.origin.position.y;
        const double origin_yaw = yawFromQuaternion(map.info.origin.orientation);
        const double cos_yaw = std::cos(origin_yaw);
        const double sin_yaw = std::sin(origin_yaw);

        for (uint32_t y = 0; y < map.info.height; ++y) {
            for (uint32_t x = 0; x < map.info.width; ++x) {
                const int8_t value = map.data[static_cast<std::size_t>(y) * map.info.width + x];
                if (value < 65) continue;
                const double local_x = (static_cast<double>(x) + 0.5) * resolution;
                const double local_y = (static_cast<double>(y) + 0.5) * resolution;
                const float world_x = static_cast<float>(origin_x + local_x * cos_yaw - local_y * sin_yaw);
                const float world_y = static_cast<float>(origin_y + local_x * sin_yaw + local_y * cos_yaw);
                for (int z = 0; z < 5; ++z) {
                    points.push_back({world_x, world_y, static_cast<float>(z) * 0.08f});
                }
            }
        }

        std::ofstream out(path, std::ios::binary);
        if (!out) return false;
        out << "# .PCD v0.7 - Point Cloud Data file format\n";
        out << "VERSION 0.7\n";
        out << "FIELDS x y z\n";
        out << "SIZE 4 4 4\n";
        out << "TYPE F F F\n";
        out << "COUNT 1 1 1\n";
        out << "WIDTH " << points.size() << "\n";
        out << "HEIGHT 1\n";
        out << "VIEWPOINT 0 0 0 1 0 0 0\n";
        out << "POINTS " << points.size() << "\n";
        out << "DATA binary\n";
        for (const auto& p : points) {
            out.write(reinterpret_cast<const char*>(p.data()), sizeof(float) * 3);
        }
        point_count = points.size();
        return static_cast<bool>(out);
    }

    bool writePointCloudPcd(const std::vector<std::array<float, 3>>& points, const std::string& path) {
        std::ofstream out(path, std::ios::binary);
        if (!out) return false;
        out << "# .PCD v0.7 - Point Cloud Data file format\n";
        out << "VERSION 0.7\n";
        out << "FIELDS x y z\n";
        out << "SIZE 4 4 4\n";
        out << "TYPE F F F\n";
        out << "COUNT 1 1 1\n";
        out << "WIDTH " << points.size() << "\n";
        out << "HEIGHT 1\n";
        out << "VIEWPOINT 0 0 0 1 0 0 0\n";
        out << "POINTS " << points.size() << "\n";
        out << "DATA binary\n";
        for (const auto& p : points) {
            out.write(reinterpret_cast<const char*>(p.data()), sizeof(float) * 3);
        }
        return static_cast<bool>(out);
    }

    bool writeMapYaml(const nav_msgs::OccupancyGrid& map, const std::string& path, const std::string& image) {
        std::ofstream yaml(path);
        if (!yaml) return false;
        yaml << "image: " << image << "\n";
        yaml << "resolution: " << map.info.resolution << "\n";
        yaml << "origin: [" << map.info.origin.position.x << ", "
             << map.info.origin.position.y << ", "
             << yawFromQuaternion(map.info.origin.orientation) << "]\n";
        yaml << "negate: 0\n";
        yaml << "occupied_thresh: 0.65\n";
        yaml << "free_thresh: 0.196\n";
        return static_cast<bool>(yaml);
    }

    bool saveLatestMapFromOccupancyGrid() {
        nav_msgs::OccupancyGrid map;
        std::string map_id;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            if (last_map_time_.isZero()) {
                ROS_WARN("[spiritwing_web] save map skipped: no /map received yet");
                return false;
            }
            map = latest_map_;
            map_id = current_map_id_.empty() ? "current" : current_map_id_;
        }

        if (map.info.width == 0 || map.info.height == 0 || map.data.empty()) {
            ROS_WARN("[spiritwing_web] save map skipped: empty occupancy grid");
            return false;
        }
        MapExportStats stats;
        for (const auto cell : map.data) {
            if (cell >= 0) stats.map_area += 1.0;
            if (cell >= 65) ++stats.point_count;
        }
        stats.map_area *= static_cast<double>(map.info.resolution) * static_cast<double>(map.info.resolution);

        const std::string base_dir = cfg_.maps_dir.empty()
            ? ("/tmp/spiritwing_web/maps/" + cfg_.sn + "/" + map_id)
            : (cfg_.maps_dir + "/" + cfg_.sn + "/" + map_id);
        if (!ensureDirectory(base_dir)) {
            ROS_WARN("[spiritwing_web] save map failed: cannot create %s", base_dir.c_str());
            return false;
        }

        const std::string pgm_path = cfg_.pgm_path.empty() ? (base_dir + "/map.pgm") : cfg_.pgm_path;
        const std::string yaml_path = cfg_.yaml_path.empty() ? (base_dir + "/map.yaml") : cfg_.yaml_path;
        const std::string upload_yaml_path = base_dir + "/map_upload.yaml";
        std::string pcd_path = cfg_.pcd_path.empty() ? (base_dir + "/cloud_map.pcd") : cfg_.pcd_path;
        const std::string pose_path = cfg_.pose_path.empty() ? (base_dir + "/pose.txt") : cfg_.pose_path;

        std::ofstream pgm(pgm_path, std::ios::binary);
        if (!pgm) {
            ROS_WARN("[spiritwing_web] save map failed: cannot open %s", pgm_path.c_str());
            return false;
        }

        const auto width = map.info.width;
        const auto height = map.info.height;
        pgm << "P5\n# CREATOR: spiritwing_web\n" << width << " " << height << "\n255\n";
        for (int y = static_cast<int>(height) - 1; y >= 0; --y) {
            for (unsigned int x = 0; x < width; ++x) {
                const int8_t occ = map.data[static_cast<std::size_t>(y) * width + x];
                unsigned char value = 205;
                if (occ >= 65) value = 0;
                else if (occ >= 0 && occ <= 19) value = 254;
                pgm.write(reinterpret_cast<const char*>(&value), 1);
            }
        }
        pgm.close();
        if (!pgm) {
            ROS_WARN("[spiritwing_web] save map failed while writing %s", pgm_path.c_str());
            return false;
        }

        if (!writeMapYaml(map, yaml_path, "map.pgm")) {
            ROS_WARN("[spiritwing_web] save map failed: cannot write %s", yaml_path.c_str());
            return false;
        }

        std::vector<std::array<float, 3>> cloud;
        ros::Time cloud_time;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            cloud = latest_point_cloud_;
            cloud_time = last_point_cloud_time_;
        }

        std::size_t pcd_points = 0;
        bool pcd_ok = false;
        if (!cloud.empty()) {
            pcd_ok = writePointCloudPcd(cloud, pcd_path);
            pcd_points = cloud.size();
            ROS_INFO("[spiritwing_web] exported real point cloud: topic=%s points=%zu age=%.2fs",
                     cfg_.pointcloud_topic.c_str(), pcd_points,
                     cloud_time.isZero() ? -1.0 : (ros::Time::now() - cloud_time).toSec());
        }
        if (pcd_ok && pcd_points > 0) {
            stats.point_count = pcd_points;
        } else {
            ROS_ERROR("[spiritwing_web] real point cloud unavailable; skip fake pcd generation, topic=%s path=%s",
                      cfg_.pointcloud_topic.c_str(), pcd_path.c_str());
            pcd_path.clear();
        }

        std::ofstream pose(pose_path);
        if (pose) {
            pose << map.info.origin.position.x << " "
                 << map.info.origin.position.y << " "
                 << yawFromQuaternion(map.info.origin.orientation) << "\n";
        }

        {
            std::lock_guard<std::mutex> lk(mutex_);
            generated_pgm_path_ = pgm_path;
            generated_yaml_path_ = yaml_path;
            generated_upload_yaml_path_ = upload_yaml_path;
            generated_pcd_path_ = pcd_path;
            generated_pose_path_ = pose_path;
            last_map_stats_ = stats;
        }
        ROS_INFO("[spiritwing_web] saved occupancy map: pgm=%s yaml=%s pcd=%s points=%zu area=%.3f",
                 pgm_path.c_str(), yaml_path.c_str(), pcd_path.c_str(), stats.point_count, stats.map_area);
        return true;
    }

    void uploadMapFiles() {
        if (cfg_.file_upload_url.empty()) {
            ROS_WARN("[spiritwing_web] upload skipped: file upload url is empty");
            return;
        }

        std::thread([this]() {
            std::string pcd_path = cfg_.pcd_path;
            std::string pgm_path = cfg_.pgm_path;
            std::string yaml_path = cfg_.yaml_path;
            std::string upload_yaml_path;
            std::string pose_path = cfg_.pose_path;
            MapExportStats stats;
            {
                std::lock_guard<std::mutex> lk(mutex_);
                if (pcd_path.empty()) pcd_path = generated_pcd_path_;
                if (pgm_path.empty()) pgm_path = generated_pgm_path_;
                if (yaml_path.empty()) yaml_path = generated_yaml_path_;
                upload_yaml_path = generated_upload_yaml_path_;
                if (pose_path.empty()) pose_path = generated_pose_path_;
                stats = last_map_stats_;
            }

            const std::string url_pcd = extractUploadUrl(runCurlUploadIfPresent(cfg_.file_upload_url, pcd_path));
            const std::string url_pgm = extractUploadUrl(runCurlUploadIfPresent(cfg_.file_upload_url, pgm_path));
            if (!url_pgm.empty() && !upload_yaml_path.empty()) {
                nav_msgs::OccupancyGrid map;
                {
                    std::lock_guard<std::mutex> lk(mutex_);
                    map = latest_map_;
                }
                writeMapYaml(map, upload_yaml_path, url_pgm);
                yaml_path = upload_yaml_path;
            }
            const std::string url_yaml = extractUploadUrl(runCurlUploadIfPresent(cfg_.file_upload_url, yaml_path));
            const std::string url_txt = extractUploadUrl(runCurlUploadIfPresent(cfg_.file_upload_url, pose_path));

            auto msg = baseResponse("upload_maps");
            msg["forward"] = true;
            msg["url_pcd"] = url_pcd;
            msg["url_txt"] = url_txt;
            msg["url_pgm"] = url_pgm;
            msg["url_yaml"] = url_yaml;
            msg["url_path"] = "";
            msg["travel_dis"] = 0.0;
            msg["map_area"] = stats.map_area;
            msg["mapping_time"] = 0.0;
            msg["point_nums"] = static_cast<double>(stats.point_count);
            msg["Point_Density"] = stats.map_area > 0.0 ? static_cast<double>(stats.point_count) / stats.map_area : 0.0;
            {
                std::lock_guard<std::mutex> lk(mutex_);
                msg["map_id"] = current_map_id_;
            }
            sendJson(msg);
            ROS_INFO("[spiritwing_web] send upload_maps map_id=%s points=%zu area=%.3f pgm=%s yaml=%s",
                     msg.value("map_id", "").c_str(), stats.point_count, stats.map_area,
                     url_pgm.c_str(), url_yaml.c_str());
        }).detach();
    }

    void runScriptAsync(const std::string& cmd, const std::string& label) {
        if (cmd.empty()) return;
        std::thread([cmd, label]() {
            ROS_INFO("[spiritwing_web] run %s script: %s", label.c_str(), cmd.c_str());
            const int rc = std::system(cmd.c_str());
            ROS_INFO("[spiritwing_web] script %s exited rc=%d", label.c_str(), rc);
        }).detach();
    }

    void onStatusTimer(const ros::TimerEvent&) {
        json msg = baseResponse("robot_status");
        nav_msgs::Odometry odom;
        mavros_msgs::State mavros_state;
        mavros_msgs::ExtendedState ext;
        sensor_msgs::BatteryState battery;
        std::string state;
        bool odom_valid = false;
        bool relocalized = false;
        std::string map_id;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            odom = latest_odom_;
            mavros_state = latest_mavros_state_;
            ext = latest_extended_state_;
            battery = latest_battery_;
            state = robot_state_;
            relocalized = relocalized_;
            map_id = current_map_id_;
            odom_valid = !last_odom_time_.isZero() && (ros::Time::now() - last_odom_time_).toSec() < 3.0;
            if (state == "INITIALIZING" && odom_valid) state = "IDLE";
        }

        const auto& p = odom.pose.pose.position;
        const auto& v = odom.twist.twist;
        const double yaw = odom_valid ? yawFromQuaternion(odom.pose.pose.orientation) : 0.0;

        msg["map_id"] = map_id;
        msg["robot_state"] = state;
        msg["current_station_id"] = "";
        msg["localize_status"] = odom_valid ? 1 : 0;
        msg["relocalize_status"] = relocalized ? 1 : 0;
        msg["cur_travel_distance"] = 0.0;
        msg["total_travel_distance"] = 0.0;
        msg["linear_velocity"] = {{"x", v.linear.x}, {"y", v.linear.y}, {"z", v.linear.z}};
        msg["angular_velocity"] = {{"x", v.angular.x}, {"y", v.angular.y}, {"z", v.angular.z}};
        msg["position"] = {{"x", odom_valid ? p.x : 0.0}, {"y", odom_valid ? p.y : 0.0}, {"z", odom_valid ? p.z : 0.0}};
        msg["orientation"] = {{"roll", 0.0}, {"pitch", 0.0}, {"yaw", yaw}};
        msg["battery"] = {
            {"voltage", battery.voltage},
            {"percentage", std::isfinite(battery.percentage) ? battery.percentage : 0.0}
        };
        msg["uav"] = {
            {"connected", mavros_state.connected},
            {"armed", mavros_state.armed},
            {"mode", mavros_state.mode},
            {"landed_state", ext.landed_state}
        };
        msg["node_status"] = {
            {"localization", {
                {"header", {{"time", ros::Time::now().toSec()}, {"status", odom_valid ? 1 : 0}}},
                {"payload", {{"loc_flag", odom_valid}, {"odometer", 0.0}, {"duration", 0}, {"localization_duration", 0}}}
            }},
            {"navigation", {
                {"header", {{"time", ros::Time::now().toSec()}, {"status", state == "NAVIGATING" ? 1 : 0}}},
                {"payload", {
                    {"goal_id", 0},
                    {"global_path_plan_status", state == "NAVIGATING" ? 1 : 0},
                    {"local_path_plan_status", state == "NAVIGATING" ? 1 : 0},
                    {"global_path_length", 0.0},
                    {"remaining_length", 0.0},
                    {"arrived_goal", false},
                    {"stop", state != "NAVIGATING"},
                    {"reserve", -1}
                }}
            }}
        };
        sendJson(msg);
        checkNavigationProgress();
    }

    void checkNavigationProgress() {
        geometry_msgs::PoseStamped next_goal;
        bool publish_next = false;
        bool send_goal_reached = false;
        bool send_task_completed = false;
        std::size_t next_index = 0;
        std::size_t total = 0;
        double dist = 0.0;

        {
            std::lock_guard<std::mutex> lk(mutex_);
            if (!move_base_sequence_active_ || !navigating_active_ || goals_.empty() || last_odom_time_.isZero()) {
                return;
            }
            if ((ros::Time::now() - active_goal_sent_time_).toSec() < cfg_.navigation_goal_min_time_s) {
                return;
            }
            if (active_goal_index_ >= goals_.size()) {
                move_base_sequence_active_ = false;
                navigating_active_ = false;
                robot_state_ = "IDLE";
                return;
            }

            const auto& goal = goals_[active_goal_index_];
            const double dx = goal.x - latest_odom_.pose.pose.position.x;
            const double dy = goal.y - latest_odom_.pose.pose.position.y;
            dist = std::hypot(dx, dy);
            if (dist > cfg_.navigation_goal_tolerance) {
                return;
            }

            send_goal_reached = true;
            const std::size_t reached_index = active_goal_index_;
            (void)reached_index;
            ++active_goal_index_;
            total = goals_.size();
            if (active_goal_index_ < goals_.size()) {
                const auto& next = goals_[active_goal_index_];
                next_goal.header.frame_id = cfg_.task_frame_id;
                next_goal.pose.position.x = next.x;
                next_goal.pose.position.y = next.y;
                next_goal.pose.position.z = next.z;
                next_goal.pose.orientation = next.q;
                next_index = active_goal_index_;
                publish_next = true;
            } else {
                move_base_sequence_active_ = false;
                navigating_active_ = false;
                manual_active_ = false;
                robot_state_ = "IDLE";
                send_task_completed = true;
            }
        }

        if (send_goal_reached) {
            auto reached = baseResponse("goal_reached");
            reached["distance"] = dist;
            sendJson(reached);
        }
        if (publish_next) {
            publishMoveBaseGoal(next_goal, next_index, total);
        }
        if (send_task_completed) {
            publishHover("navigation_completed");
            auto done = baseResponse("task_completed");
            sendJson(done);
        }
    }

    void onManualTimer(const ros::TimerEvent&) {
        geometry_msgs::Twist twist;
        bool active = false;
        bool timed_out = false;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            if (manual_active_ && (ros::Time::now() - last_manual_time_).toSec() <= cfg_.manual_timeout_s) {
                twist = manual_twist_;
                active = true;
            } else if (manual_active_) {
                manual_active_ = false;
                robot_state_ = "IDLE";
                timed_out = true;
            }
        }
        if (timed_out) {
            geometry_msgs::Twist zero;
            pub_mavros_manual_vel_.publish(zero);
            pub_cmd_vel_.publish(zero);
            publishCommandJson("manual_timeout_stop", {});
        }
        if (active) {
            if (cfg_.command_backend == "mavros") pub_mavros_manual_vel_.publish(twist);
            else publishManualTwist(twist, "hold");
        }
    }

    void onRealtimeCloudTimer(const ros::TimerEvent&) {
        if (!cfg_.enable_realtime_cloud || realtime_cloud_uploading_.exchange(true)) return;

        std::vector<std::array<float, 3>> cloud;
        ros::Time cloud_time;
        bool mapping = false;
        {
            std::lock_guard<std::mutex> lk(mutex_);
            mapping = mapping_active_;
            cloud = latest_point_cloud_;
            cloud_time = last_point_cloud_time_;
        }

        if (mapping || cloud.empty() || cloud_time.isZero()) {
            realtime_cloud_uploading_ = false;
            return;
        }
        if (cfg_.realtime_cloud_stale_timeout_s > 0.0 &&
            (ros::Time::now() - cloud_time).toSec() > cfg_.realtime_cloud_stale_timeout_s) {
            ROS_WARN_THROTTLE(10.0, "[spiritwing_web] realtime cloud skipped: stale point cloud age=%.2fs",
                              (ros::Time::now() - cloud_time).toSec());
            realtime_cloud_uploading_ = false;
            return;
        }

        const std::size_t max_points = std::max<std::size_t>(1, cfg_.realtime_cloud_max_points);
        if (cloud.size() > max_points) {
            std::vector<std::array<float, 3>> sampled;
            sampled.reserve(max_points);
            const std::size_t stride = std::max<std::size_t>(1, cloud.size() / max_points);
            for (std::size_t i = 0; i < cloud.size() && sampled.size() < max_points; i += stride) {
                sampled.push_back(cloud[i]);
            }
            cloud.swap(sampled);
        }

        std::thread([this, cloud = std::move(cloud)]() {
            const std::string dir = (cfg_.maps_dir.empty() ? "/tmp/spiritwing_web/maps" : cfg_.maps_dir)
                + "/" + cfg_.sn + "/realtime";
            if (!ensureDirectory(dir)) {
                ROS_WARN("[spiritwing_web] realtime cloud upload skipped: cannot create %s", dir.c_str());
                realtime_cloud_uploading_ = false;
                return;
            }
            const std::string pcd_path = dir + "/realtime_cloud.pcd";
            if (!writePointCloudPcd(cloud, pcd_path)) {
                ROS_WARN("[spiritwing_web] realtime cloud upload skipped: write pcd failed");
                realtime_cloud_uploading_ = false;
                return;
            }
            const std::string key = extractUploadUrl(runCurlUploadIfPresent(cfg_.file_upload_url, pcd_path));
            if (!key.empty()) {
                auto msg = baseResponse("upload_realtime_point_cloud");
                msg["url"] = toDownloadUrl(cfg_.file_download_url, key);
                sendJson(msg);
                ROS_INFO("[spiritwing_web] send upload_realtime_point_cloud points=%zu key=%s url=%s",
                         cloud.size(), key.c_str(), msg["url"].get<std::string>().c_str());
            }
            realtime_cloud_uploading_ = false;
        }).detach();
    }

    void onMavrosState(const mavros_msgs::State::ConstPtr& msg) {
        std::lock_guard<std::mutex> lk(mutex_);
        latest_mavros_state_ = *msg;
    }

    void onExtendedState(const mavros_msgs::ExtendedState::ConstPtr& msg) {
        std::lock_guard<std::mutex> lk(mutex_);
        latest_extended_state_ = *msg;
    }

    void onBattery(const sensor_msgs::BatteryState::ConstPtr& msg) {
        std::lock_guard<std::mutex> lk(mutex_);
        latest_battery_ = *msg;
    }

    void onOdom(const nav_msgs::Odometry::ConstPtr& msg) {
        std::lock_guard<std::mutex> lk(mutex_);
        latest_odom_ = *msg;
        last_odom_time_ = ros::Time::now();
        if (robot_state_ == "INITIALIZING") robot_state_ = "IDLE";
    }

    void onMap(const nav_msgs::OccupancyGrid::ConstPtr& msg) {
        std::lock_guard<std::mutex> lk(mutex_);
        latest_map_ = *msg;
        last_map_time_ = ros::Time::now();
    }

    void onPatrolStateText(const std_msgs::String::ConstPtr& msg) {
        ROS_INFO("[spiritwing_web] patrol_state placeholder: %s", msg->data.c_str());
        try {
            const json j = json::parse(msg->data);
            const std::string event = j.value("event", "");
            if (event == "goal_reached") {
                auto out = baseResponse("goal_reached");
                sendJson(out);
            } else if (event == "task_completed") {
                {
                    std::lock_guard<std::mutex> lk(mutex_);
                    navigating_active_ = false;
                    robot_state_ = "IDLE";
                }
                auto out = baseResponse("task_completed");
                sendJson(out);
            }
        } catch (...) {
        }
    }

    void onPointCloud(const sensor_msgs::PointCloud2::ConstPtr& msg) {
        std::vector<std::array<float, 3>> cloud;
        const std::size_t total = static_cast<std::size_t>(msg->width) * static_cast<std::size_t>(msg->height);
        cloud.reserve(std::min<std::size_t>(total, 300000));
        try {
            sensor_msgs::PointCloud2ConstIterator<float> iter_x(*msg, "x");
            sensor_msgs::PointCloud2ConstIterator<float> iter_y(*msg, "y");
            sensor_msgs::PointCloud2ConstIterator<float> iter_z(*msg, "z");
            const std::size_t max_points = 300000;
            const std::size_t stride = std::max<std::size_t>(1, total / max_points);
            std::size_t idx = 0;
            for (; iter_x != iter_x.end(); ++iter_x, ++iter_y, ++iter_z, ++idx) {
                if (idx % stride != 0) continue;
                const float x = *iter_x;
                const float y = *iter_y;
                const float z = *iter_z;
                if (std::isfinite(x) && std::isfinite(y) && std::isfinite(z)) {
                    cloud.push_back({x, y, z});
                }
            }
        } catch (const std::exception& e) {
            ROS_WARN_THROTTLE(5.0, "[spiritwing_web] point cloud parse failed from %s: %s",
                              cfg_.pointcloud_topic.c_str(), e.what());
            return;
        }
        std::lock_guard<std::mutex> lk(mutex_);
        latest_point_cloud_ = std::move(cloud);
        last_point_cloud_time_ = ros::Time::now();
    }
};

int main(int argc, char** argv) {
    ros::init(argc, argv, "spiritwing_web_node");
    ros::NodeHandle nh("~");

    try {
        SpiritWingWebNode node(nh);
        node.start();
        ros::spin();
    } catch (const std::exception& e) {
        ROS_FATAL("[spiritwing_web] fatal: %s", e.what());
        return 1;
    }
    return 0;
}
