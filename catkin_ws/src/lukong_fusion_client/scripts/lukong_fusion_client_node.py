#!/usr/bin/env python3
import json
import math
import os
import shutil
import threading
import time
import uuid
from pathlib import Path

import numpy as np
import requests
import rospy
import sensor_msgs.point_cloud2 as pc2
from flask import Flask, send_from_directory
from nav_msgs.msg import Odometry
from sensor_msgs.msg import PointCloud2
from std_msgs.msg import String


def _stamp_to_dict(stamp):
    return {
        "sec": int(stamp.secs),
        "nanosec": int(stamp.nsecs),
    }


def _quat_to_yaw(q):
    siny_cosp = 2.0 * (q.w * q.z + q.x * q.y)
    cosy_cosp = 1.0 - 2.0 * (q.y * q.y + q.z * q.z)
    return math.atan2(siny_cosp, cosy_cosp)


def _angle_diff(a, b):
    d = a - b
    while d > math.pi:
        d -= 2.0 * math.pi
    while d < -math.pi:
        d += 2.0 * math.pi
    return d


class PcdFileServer:
    def __init__(self, host, port, pcd_dir):
        self.host = host
        self.port = int(port)
        self.pcd_dir = Path(pcd_dir)
        self.app = Flask(__name__)

        @self.app.route("/pcd/<path:filename>")
        def serve_pcd(filename):
            return send_from_directory(str(self.pcd_dir), filename)

    def start(self):
        thread = threading.Thread(target=self._run, daemon=True)
        thread.start()

    def _run(self):
        self.app.run(host=self.host, port=self.port, threaded=True, use_reloader=False)


class LukongFusionClient:
    def __init__(self):
        ns = "~"
        self.fusion_server = rospy.get_param(ns + "fusion_server", "http://192.168.50.165:8080").rstrip("/")
        self.robot_ip = rospy.get_param(ns + "robot_ip", "192.168.50.11")
        self.http_host = rospy.get_param(ns + "http_host", "0.0.0.0")
        self.http_port = int(rospy.get_param(ns + "http_port", 5000))
        self.robot_id = rospy.get_param(ns + "robot_id", "SPIRITWING_LUKONG_SN")
        self.area_id = rospy.get_param(ns + "area_id", "123")
        self.frame_id = rospy.get_param(ns + "frame_id", "map")

        self.odom_topic = rospy.get_param(ns + "odom_topic", "/Odometry_loc")
        self.fallback_odom_topic = rospy.get_param(ns + "fallback_odom_topic", "/mavros/local_position/odom")
        self.pointcloud_topic = rospy.get_param(ns + "pointcloud_topic", "/cloud_registered_1")

        self.pcd_dir = Path(rospy.get_param(ns + "pcd_dir", "/tmp/lukong_fusion_client/pcd"))
        self.clear_pcd_on_start = bool(rospy.get_param(ns + "clear_pcd_on_start", True))
        self.max_saved_pcd_files = int(rospy.get_param(ns + "max_saved_pcd_files", 200))

        self.keyframe_check_period_s = float(rospy.get_param(ns + "keyframe_check_period_s", 1.0))
        self.keyframe_min_interval_s = float(rospy.get_param(ns + "keyframe_min_interval_s", 2.0))
        self.keyframe_distance_m = float(rospy.get_param(ns + "keyframe_distance_m", 0.8))
        self.keyframe_yaw_rad = math.radians(float(rospy.get_param(ns + "keyframe_yaw_deg", 12.0)))
        self.send_first_keyframe_immediately = bool(rospy.get_param(ns + "send_first_keyframe_immediately", True))
        self.send_policy = rospy.get_param(ns + "send_policy", "slam_command")
        self.slam_command_topic = rospy.get_param(ns + "slam_command_topic", "/spiritwing/command_json_placeholder")
        self.slam_start_delay_s = float(rospy.get_param(ns + "slam_start_delay_s", 8.0))
        self.update_area_id_from_slam_command = bool(rospy.get_param(ns + "update_area_id_from_slam_command", True))

        self.max_points_per_keyframe = int(rospy.get_param(ns + "max_points_per_keyframe", 8000))
        self.request_timeout_s = float(rospy.get_param(ns + "request_timeout_s", 60.0))
        self.log_payload = bool(rospy.get_param(ns + "log_payload", False))

        self.latest_odom = None
        self.latest_cloud = None
        self.latest_odom_time = None
        self.latest_cloud_time = None
        self.lock = threading.Lock()

        self.last_sent_pose = None
        self.last_sent_yaw = None
        self.last_sent_time = 0.0
        self.keyframe_id = 0
        self.sent_count = 0
        self.success_count = 0
        self.fusion_active = self.send_policy == "always"
        self.pending_start_time = None

        self._prepare_pcd_dir()
        self.file_server = PcdFileServer(self.http_host, self.http_port, self.pcd_dir)
        self.file_server.start()

        rospy.Subscriber(self.odom_topic, Odometry, self._odom_cb, queue_size=10)
        if self.fallback_odom_topic and self.fallback_odom_topic != self.odom_topic:
            rospy.Subscriber(self.fallback_odom_topic, Odometry, self._fallback_odom_cb, queue_size=10)
        rospy.Subscriber(self.pointcloud_topic, PointCloud2, self._cloud_cb, queue_size=2)
        if self.send_policy == "slam_command":
            rospy.Subscriber(self.slam_command_topic, String, self._slam_command_cb, queue_size=10)

        self.timer = rospy.Timer(rospy.Duration(self.keyframe_check_period_s), self._timer_cb)

        rospy.loginfo("Lukong fusion client started")
        rospy.loginfo("Fusion server: %s", self.fusion_server)
        rospy.loginfo("Topics: odom=%s fallback=%s pointcloud=%s",
                      self.odom_topic, self.fallback_odom_topic, self.pointcloud_topic)
        rospy.loginfo("Send policy: %s%s",
                      self.send_policy,
                      "" if self.send_policy != "slam_command" else " topic=" + self.slam_command_topic)

    def _prepare_pcd_dir(self):
        if self.clear_pcd_on_start and self.pcd_dir.exists():
            shutil.rmtree(str(self.pcd_dir))
        self.pcd_dir.mkdir(parents=True, exist_ok=True)

    def _odom_cb(self, msg):
        with self.lock:
            self.latest_odom = msg
            self.latest_odom_time = rospy.Time.now()

    def _fallback_odom_cb(self, msg):
        with self.lock:
            if self.latest_odom is None:
                self.latest_odom = msg
                self.latest_odom_time = rospy.Time.now()

    def _cloud_cb(self, msg):
        with self.lock:
            self.latest_cloud = msg
            self.latest_cloud_time = rospy.Time.now()

    def _slam_command_cb(self, msg):
        try:
            data = json.loads(msg.data)
        except Exception as exc:
            rospy.logwarn("Ignore invalid slam command json: %s", exc)
            return

        command = data.get("command")
        if command == "slam_start":
            with self.lock:
                if self.update_area_id_from_slam_command and data.get("area_id"):
                    self.area_id = str(data.get("area_id"))
                self._reset_keyframe_session_locked()
                self.pending_start_time = time.time() + self.slam_start_delay_s
                self.fusion_active = False
            rospy.loginfo("Received slam_start, fusion keyframe sending will start after %.1fs, area_id=%s",
                          self.slam_start_delay_s, self.area_id)
        elif command == "slam_stop":
            with self.lock:
                self.fusion_active = False
                self.pending_start_time = None
            rospy.loginfo("Received slam_stop, fusion keyframe sending stopped")

    def _reset_keyframe_session_locked(self):
        self.last_sent_pose = None
        self.last_sent_yaw = None
        self.last_sent_time = 0.0
        self.keyframe_id = 0
        self.sent_count = 0
        self.success_count = 0
        self._prepare_pcd_dir()

    def _timer_cb(self, _event):
        try:
            with self.lock:
                odom = self.latest_odom
                cloud = self.latest_cloud
                if self.pending_start_time is not None and time.time() >= self.pending_start_time:
                    self.fusion_active = True
                    self.pending_start_time = None
                    rospy.loginfo("Fusion keyframe sending is now active")
                fusion_active = self.fusion_active

            if odom is None or cloud is None:
                rospy.logwarn_throttle(10.0, "Waiting for odom and pointcloud before sending fusion keyframes")
                return
            if not fusion_active:
                rospy.loginfo_throttle(10.0, "Fusion keyframe sending is inactive, waiting for slam_start")
                return

            now = time.time()
            if now - self.last_sent_time < self.keyframe_min_interval_s:
                return

            pose = odom.pose.pose
            yaw = _quat_to_yaw(pose.orientation)
            if not self._should_send_keyframe(pose, yaw):
                return

            self._send_keyframe(odom, cloud)
            self.last_sent_pose = pose
            self.last_sent_yaw = yaw
            self.last_sent_time = now
        except Exception as exc:
            rospy.logerr("Fusion keyframe timer failed: %s", exc)

    def _should_send_keyframe(self, pose, yaw):
        if self.last_sent_pose is None:
            return self.send_first_keyframe_immediately

        dx = pose.position.x - self.last_sent_pose.position.x
        dy = pose.position.y - self.last_sent_pose.position.y
        dz = pose.position.z - self.last_sent_pose.position.z
        distance = math.sqrt(dx * dx + dy * dy + dz * dz)
        yaw_delta = abs(_angle_diff(yaw, self.last_sent_yaw))
        return distance >= self.keyframe_distance_m or yaw_delta >= self.keyframe_yaw_rad

    def _send_keyframe(self, odom, cloud):
        self.keyframe_id += 1
        pcd_path = self._save_pointcloud_as_pcd(cloud)
        pcd_url = "http://{}:{}/pcd/{}".format(self.robot_ip, self.http_port, pcd_path.name)
        stamp = odom.header.stamp if odom.header.stamp != rospy.Time() else rospy.Time.now()

        payload = {
            "type": "keyframe",
            "forward": True,
            "robot_id": self.robot_id,
            "area_id": self.area_id,
            "keyframe_id": self.keyframe_id,
            "header": {
                "stamp": _stamp_to_dict(stamp),
                "frame_id": odom.header.frame_id or self.frame_id,
            },
            "pose": {
                "position": {
                    "x": odom.pose.pose.position.x,
                    "y": odom.pose.pose.position.y,
                    "z": odom.pose.pose.position.z,
                },
                "orientation": {
                    "x": odom.pose.pose.orientation.x,
                    "y": odom.pose.pose.orientation.y,
                    "z": odom.pose.pose.orientation.z,
                    "w": odom.pose.pose.orientation.w,
                },
            },
            "url": pcd_url,
            "timestamp": _stamp_to_dict(stamp),
        }

        if self.log_payload:
            rospy.loginfo("Fusion payload: %s", payload)

        self.sent_count += 1
        url = self.fusion_server + "/keyframe_data"
        response = requests.post(url, json=payload, timeout=self.request_timeout_s)
        if response.status_code == 200:
            self.success_count += 1
            rospy.loginfo("Sent fusion keyframe %s/%s: robot_id=%s area_id=%s keyframe_id=%s pcd=%s",
                          self.success_count, self.sent_count, self.robot_id, self.area_id,
                          self.keyframe_id, pcd_url)
        else:
            rospy.logwarn("Fusion keyframe rejected: status=%s body=%s",
                          response.status_code, response.text)
        self._trim_old_pcd_files()

    def _save_pointcloud_as_pcd(self, cloud_msg):
        fields = {field.name for field in cloud_msg.fields}
        field_names = ("x", "y", "z", "intensity") if "intensity" in fields else ("x", "y", "z")
        points_iter = pc2.read_points(cloud_msg, field_names=field_names, skip_nans=True)

        points = []
        for idx, point in enumerate(points_iter):
            if self.max_points_per_keyframe > 0 and idx >= self.max_points_per_keyframe:
                break
            if len(point) >= 4:
                points.append([point[0], point[1], point[2], point[3]])
            else:
                points.append([point[0], point[1], point[2], 0.0])

        if not points:
            raise RuntimeError("pointcloud has no valid xyz points")

        arr = np.asarray(points, dtype=np.float32)
        filename = "{:06d}_{}.pcd".format(self.keyframe_id, uuid.uuid4().hex[:8])
        path = self.pcd_dir / filename
        header = (
            "# .PCD v0.7\n"
            "VERSION 0.7\n"
            "FIELDS x y z intensity\n"
            "SIZE 4 4 4 4\n"
            "TYPE F F F F\n"
            "COUNT 1 1 1 1\n"
            "WIDTH {count}\n"
            "HEIGHT 1\n"
            "VIEWPOINT 0 0 0 1 0 0 0\n"
            "POINTS {count}\n"
            "DATA ascii\n"
        ).format(count=len(arr))

        with path.open("w") as f:
            f.write(header)
            np.savetxt(f, arr, fmt="%.6f %.6f %.6f %.6f")
        return path

    def _trim_old_pcd_files(self):
        if self.max_saved_pcd_files <= 0:
            return
        files = sorted(self.pcd_dir.glob("*.pcd"), key=lambda p: p.stat().st_mtime, reverse=True)
        for old_file in files[self.max_saved_pcd_files:]:
            try:
                old_file.unlink()
            except OSError:
                pass


def main():
    rospy.init_node("lukong_fusion_client")
    LukongFusionClient()
    rospy.spin()


if __name__ == "__main__":
    main()
