#!/usr/bin/env python3
import importlib.util
from pathlib import Path
import unittest

from nav_msgs.msg import Odometry


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "scripts" / "fastlio_odometry_adapter.py"


def load_adapter_module(test_case):
    test_case.assertTrue(
        MODULE_PATH.exists(),
        "FAST-LIO odometry adapter implementation is missing",
    )
    spec = importlib.util.spec_from_file_location("fastlio_odometry_adapter", MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class FastlioOdometryAdapterTests(unittest.TestCase):
    def make_message(self):
        message = Odometry()
        message.header.seq = 17
        message.header.stamp.secs = 123
        message.header.stamp.nsecs = 456
        message.header.frame_id = "camera_init"
        message.child_frame_id = "body"
        message.pose.pose.position.x = 1.25
        message.pose.pose.position.y = -2.5
        message.pose.pose.position.z = 0.75
        message.pose.pose.orientation.x = 0.1
        message.pose.pose.orientation.y = 0.2
        message.pose.pose.orientation.z = 0.3
        message.pose.pose.orientation.w = 0.9
        message.pose.covariance = [float(index) for index in range(36)]
        message.twist.twist.linear.x = 4.0
        message.twist.twist.angular.z = -0.5
        message.twist.covariance = [float(100 + index) for index in range(36)]
        return message

    def test_rewrites_semantic_frames_and_preserves_measurement(self):
        adapter = load_adapter_module(self)
        source = self.make_message()

        converted = adapter.adapt_odometry(
            source,
            expected_frame_id="camera_init",
            expected_child_frame_id="body",
            output_frame_id="odom",
            output_child_frame_id="base_link",
        )

        self.assertIsNot(converted, source)
        self.assertEqual(source.header.frame_id, "camera_init")
        self.assertEqual(source.child_frame_id, "body")
        self.assertEqual(converted.header.frame_id, "odom")
        self.assertEqual(converted.child_frame_id, "base_link")
        self.assertEqual(converted.header.seq, source.header.seq)
        self.assertEqual(converted.header.stamp, source.header.stamp)
        self.assertEqual(converted.pose, source.pose)
        self.assertEqual(converted.twist, source.twist)

    def test_accepts_leading_slashes_in_fastlio_frames(self):
        adapter = load_adapter_module(self)
        source = self.make_message()
        source.header.frame_id = "/camera_init"
        source.child_frame_id = "/body"

        converted = adapter.adapt_odometry(
            source,
            expected_frame_id="camera_init",
            expected_child_frame_id="body",
            output_frame_id="odom",
            output_child_frame_id="base_link",
        )

        self.assertEqual(converted.header.frame_id, "odom")
        self.assertEqual(converted.child_frame_id, "base_link")

    def test_rejects_unexpected_parent_frame(self):
        adapter = load_adapter_module(self)
        source = self.make_message()
        source.header.frame_id = "world"

        with self.assertRaises(adapter.FrameContractError):
            adapter.adapt_odometry(source)

    def test_rejects_unexpected_child_frame(self):
        adapter = load_adapter_module(self)
        source = self.make_message()
        source.child_frame_id = "base_link"

        with self.assertRaises(adapter.FrameContractError):
            adapter.adapt_odometry(source)


if __name__ == "__main__":
    unittest.main()
