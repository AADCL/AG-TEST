#!/usr/bin/env python3
import pathlib
import sys
import unittest


PACKAGE_ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PACKAGE_ROOT / "src"))

from a8_mini_camera.core import (  # noqa: E402
    CameraConfig,
    ReconnectPolicy,
    build_rtsp_url,
)


class CameraConfigTests(unittest.TestCase):
    def test_builds_a8_main_stream_url_from_ipv4_address(self):
        self.assertEqual(
            build_rtsp_url("192.168.144.25"),
            "rtsp://192.168.144.25:8554/main.264",
        )

    def test_rejects_invalid_camera_address(self):
        with self.assertRaisesRegex(ValueError, "camera_ip"):
            build_rtsp_url("camera.local")

    def test_validates_expected_defaults(self):
        config = CameraConfig()
        self.assertEqual(config.camera_ip, "192.168.144.25")
        self.assertEqual(config.rtsp_url, "rtsp://192.168.144.25:8554/main.264")
        self.assertEqual(config.image_topic, "/a8_cam/image_raw")
        self.assertEqual(config.frame_id, "a8_cam")
        self.assertEqual(config.publish_rate, 30.0)

    def test_rejects_non_absolute_image_topic(self):
        with self.assertRaisesRegex(ValueError, "image_topic"):
            CameraConfig(image_topic="a8_cam/image_raw")

    def test_rejects_non_positive_publish_rate(self):
        with self.assertRaisesRegex(ValueError, "publish_rate"):
            CameraConfig(publish_rate=0.0)


class ReconnectPolicyTests(unittest.TestCase):
    def test_delay_increases_to_bound_and_reset_restores_initial_delay(self):
        policy = ReconnectPolicy(initial_delay=0.5, maximum_delay=2.0)
        self.assertEqual([policy.next_delay() for _ in range(4)], [0.5, 1.0, 2.0, 2.0])
        policy.reset()
        self.assertEqual(policy.next_delay(), 0.5)

    def test_rejects_invalid_delay_bounds(self):
        with self.assertRaisesRegex(ValueError, "initial_delay"):
            ReconnectPolicy(initial_delay=0.0, maximum_delay=2.0)
        with self.assertRaisesRegex(ValueError, "maximum_delay"):
            ReconnectPolicy(initial_delay=2.0, maximum_delay=1.0)


if __name__ == "__main__":
    unittest.main()
