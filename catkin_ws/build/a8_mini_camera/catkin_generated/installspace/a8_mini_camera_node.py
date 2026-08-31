#!/usr/bin/env python3
"""ROS1 bridge from a SIYI A8 Mini RTSP stream to sensor_msgs/Image."""

import os
import sys
from typing import Optional

import cv2
from cv_bridge import CvBridge, CvBridgeError
import rospy
from sensor_msgs.msg import Image

from a8_mini_camera.core import CameraConfig, ReconnectPolicy


class A8MiniCameraNode:
    def __init__(self, config: CameraConfig) -> None:
        self._config = config
        self._bridge = CvBridge()
        self._publisher = rospy.Publisher(config.image_topic, Image, queue_size=1)
        self._capture: Optional[cv2.VideoCapture] = None
        self._backoff = ReconnectPolicy(
            config.reconnect_initial_delay,
            config.reconnect_maximum_delay,
        )

    def _release_capture(self) -> None:
        if self._capture is not None:
            self._capture.release()
            self._capture = None

    def _connect(self) -> bool:
        self._release_capture()
        capture = cv2.VideoCapture(self._config.rtsp_url, cv2.CAP_FFMPEG)
        capture.set(cv2.CAP_PROP_BUFFERSIZE, 1)
        if not capture.isOpened():
            capture.release()
            return False
        self._capture = capture
        self._backoff.reset()
        rospy.loginfo("A8 Mini RTSP connected: %s", self._config.rtsp_url)
        return True

    def _wait_before_reconnect(self, reason: str) -> None:
        delay = self._backoff.next_delay()
        rospy.logwarn_throttle(
            5.0,
            "A8 Mini RTSP %s; reconnecting in %.1f s" % (reason, delay),
        )
        rospy.sleep(delay)

    def spin(self) -> None:
        rate = rospy.Rate(self._config.publish_rate)
        try:
            while not rospy.is_shutdown():
                if self._capture is None and not self._connect():
                    self._wait_before_reconnect("open failed")
                    continue

                ok, frame = self._capture.read()
                if not ok or frame is None or frame.size == 0:
                    self._release_capture()
                    self._wait_before_reconnect("read failed")
                    continue

                try:
                    message = self._bridge.cv2_to_imgmsg(frame, encoding="bgr8")
                except CvBridgeError as error:
                    rospy.logerr_throttle(5.0, "A8 Mini cv_bridge conversion failed: %s", error)
                    continue
                message.header.stamp = rospy.Time.now()
                message.header.frame_id = self._config.frame_id
                self._publisher.publish(message)
                rospy.loginfo_once(
                    "A8 Mini published first frame on %s", self._config.image_topic
                )
                rate.sleep()
        finally:
            self._release_capture()


def load_config() -> CameraConfig:
    return CameraConfig(
        camera_ip=str(rospy.get_param("~camera_ip", "192.168.144.25")),
        image_topic=str(rospy.get_param("~image_topic", "/a8_cam/image_raw")),
        frame_id=str(rospy.get_param("~frame_id", "a8_cam")),
        publish_rate=float(rospy.get_param("~publish_rate", 30.0)),
        reconnect_initial_delay=float(rospy.get_param("~reconnect_initial_delay", 1.0)),
        reconnect_maximum_delay=float(rospy.get_param("~reconnect_maximum_delay", 8.0)),
    )


def main() -> int:
    os.environ.setdefault(
        "OPENCV_FFMPEG_CAPTURE_OPTIONS",
        "rtsp_transport;tcp|stimeout;5000000",
    )
    rospy.init_node("a8_mini_camera")
    try:
        config = load_config()
    except (TypeError, ValueError) as error:
        rospy.logfatal("Invalid A8 Mini camera configuration: %s", error)
        return 2

    rospy.loginfo(
        "A8 Mini camera bridge ready source=%s topic=%s frame=%s max_rate=%.1f",
        config.rtsp_url,
        config.image_topic,
        config.frame_id,
        config.publish_rate,
    )
    A8MiniCameraNode(config).spin()
    return 0


if __name__ == "__main__":
    sys.exit(main())
