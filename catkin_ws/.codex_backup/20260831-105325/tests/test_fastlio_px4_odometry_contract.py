#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FastlioPx4OdometryContractTests(unittest.TestCase):
    def test_full_launch_adapts_fastlio_frames_for_mavros_odometry(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(
            encoding="utf-8"
        )

        self.assertIn('name="start_fastlio_odometry_to_px4" default="false"', text)
        self.assertIn('pkg="car_bringup"', text)
        self.assertIn('type="fastlio_odometry_adapter.py"', text)
        self.assertIn('name="fastlio_odometry_to_px4"', text)
        self.assertIn('if="$(arg start_fastlio_odometry_to_px4)"', text)
        self.assertIn('name="input_topic" value="/Odometry"', text)
        self.assertIn('name="output_topic" value="/mavros/odometry/out"', text)
        self.assertIn('name="expected_frame_id" value="camera_init"', text)
        self.assertIn('name="expected_child_frame_id" value="body"', text)
        self.assertIn('name="output_frame_id" value="odom"', text)
        self.assertIn('name="output_child_frame_id" value="base_link"', text)
        self.assertNotIn('pkg="topic_tools"', text)

    def test_manual_mapping_enables_single_px4_external_odometry_path(self):
        text = (ROOT / "launch" / "manual_mapping.launch").read_text(
            encoding="utf-8"
        )

        self.assertIn('name="start_mavros" default="true"', text)
        self.assertIn('name="start_fastlio_odometry_to_px4" value="true"', text)
        self.assertIn('name="start_vision_to_mavros" value="false"', text)

    def test_default_fcu_device_matches_the_connected_cuav(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(
            encoding="utf-8"
        )

        self.assertIn(
            'name="fcu_url" '
            'default="/dev/serial/by-id/usb-CUAV_PX4_CUAV_Nora_0-if00:57600"',
            text,
        )

    def test_adapter_is_installed_and_topic_tools_is_not_required(self):
        cmake = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
        package = (ROOT / "package.xml").read_text(encoding="utf-8")

        self.assertIn("scripts/fastlio_odometry_adapter.py", cmake)
        self.assertNotIn("<exec_depend>topic_tools</exec_depend>", package)


if __name__ == "__main__":
    unittest.main()
