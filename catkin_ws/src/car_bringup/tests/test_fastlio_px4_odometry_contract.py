#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FastlioPx4OdometryContractTests(unittest.TestCase):
    def test_shared_fastlio_pipeline_adapts_frames_for_mavros_odometry(self):
        text = (ROOT / "launch" / "fastlio_pipeline.launch").read_text(
            encoding="utf-8"
        )

        self.assertIn('name="start_fastlio_odometry_to_px4" default="true"', text)
        self.assertIn('pkg="car_bringup"', text)
        self.assertIn('type="fastlio_odometry_adapter.py"', text)
        self.assertIn('name="fastlio_odometry_to_px4"', text)
        self.assertIn('if="$(arg start_fastlio_odometry_to_px4)"', text)
        self.assertIn('name="input_topic" value="$(arg odometry_input_topic)"', text)
        self.assertIn('name="output_topic" value="$(arg mavros_odometry_output_topic)"', text)
        self.assertIn('name="expected_frame_id" value="$(arg camera_init_frame)"', text)
        self.assertIn('name="expected_child_frame_id" value="$(arg body_frame)"', text)
        self.assertIn('name="output_frame_id" value="$(arg odom_frame)"', text)
        self.assertIn('name="output_child_frame_id" value="$(arg base_frame)"', text)
        self.assertNotIn('pkg="topic_tools"', text)

    def test_mapping_uses_single_px4_external_odometry_path_without_base(self):
        text = (ROOT / "launch" / "mapping_system.launch").read_text(
            encoding="utf-8"
        )

        self.assertIn('name="start_fastlio_odometry_to_px4" default="true"', text)
        self.assertIn('$(find car_bringup)/launch/fastlio_pipeline.launch', text)
        self.assertNotIn("$(find mavros)/launch/px4.launch", text)
        self.assertNotIn("vision_to_mavros", text)

    def test_default_fcu_device_matches_the_connected_cuav(self):
        text = (ROOT / "launch" / "base_system.launch").read_text(
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
