#!/usr/bin/env python3
"""Single authority for the world -> camera_init transform."""

import copy
import threading

from geometry_msgs.msg import TransformStamped
import rospy
from std_msgs.msg import Bool
import tf2_ros


class WorldTfOwner:
    def __init__(self):
        self._mode = rospy.get_param("~mode", "localization")
        if self._mode not in ("mapping", "localization"):
            raise rospy.ROSInitException("~mode must be mapping or localization")
        self._map_frame = rospy.get_param("~map_frame", "world")
        self._odom_frame = rospy.get_param("~odom_frame", "camera_init")
        rate = float(rospy.get_param("~rate", 20.0))
        if rate <= 0.0:
            raise rospy.ROSInitException("~rate must be positive")

        self._lock = threading.RLock()
        self._localized = False
        self._latest = None
        self._broadcaster = tf2_ros.TransformBroadcaster()
        rospy.Subscriber(
            "/ground_air/localization/map_to_odom",
            TransformStamped,
            self._transform_callback,
            queue_size=1,
        )
        rospy.Subscriber(
            "/ground_air/localization/valid",
            Bool,
            self._valid_callback,
            queue_size=1,
        )
        self._timer = rospy.Timer(rospy.Duration(1.0 / rate), self._timer_callback)

    def _transform_callback(self, message):
        if message.header.frame_id != self._map_frame or message.child_frame_id != self._odom_frame:
            rospy.logerr_throttle(
                2.0,
                "map_to_odom frame mismatch: expected %s -> %s, received %s -> %s",
                self._map_frame,
                self._odom_frame,
                message.header.frame_id,
                message.child_frame_id,
            )
            return
        with self._lock:
            self._latest = copy.deepcopy(message)

    def _valid_callback(self, message):
        with self._lock:
            self._localized = bool(message.data)

    def _identity(self):
        message = TransformStamped()
        message.header.frame_id = self._map_frame
        message.child_frame_id = self._odom_frame
        message.transform.rotation.w = 1.0
        return message

    def _timer_callback(self, _event):
        with self._lock:
            if self._mode == "mapping":
                message = self._identity()
            elif self._localized and self._latest is not None:
                message = copy.deepcopy(self._latest)
            else:
                return
        message.header.stamp = rospy.Time.now()
        message.child_frame_id = self._odom_frame
        self._broadcaster.sendTransform(message)


if __name__ == "__main__":
    rospy.init_node("ground_air_world_tf_owner")
    WorldTfOwner()
    rospy.spin()
