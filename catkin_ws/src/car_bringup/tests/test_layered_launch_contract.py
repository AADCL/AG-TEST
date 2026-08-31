#!/usr/bin/env python3
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT.parent


class LayeredLaunchContractTests(unittest.TestCase):
    def launch_text(self, name):
        path = ROOT / "launch" / name
        self.assertTrue(path.is_file(), "missing launch file: {}".format(name))
        text = path.read_text(encoding="utf-8")
        ET.fromstring(text)
        self.assertIn("<!--", text, "launch file must explain its ownership and dependencies")
        return text

    def test_base_starts_only_hardware_and_base_tf(self):
        text = self.launch_text("base_system.launch")
        self.assertIn("$(find mavros)/launch/px4.launch", text)
        self.assertIn("$(find livox_ros_driver2)/launch_ROS1/msg_MID360.launch", text)
        self.assertIn('name="odom_camera_init_broadcaster"', text)
        self.assertIn('name="base_link_body_broadcaster"', text)
        for forbidden in (
            "fast_lio_open3d",
            "pcl_test",
            "dynamic_mapping",
            "ground_air_mapping",
            "ground_air_localization",
            "teb_local_planner_tutorials",
            "ground_air_control",
            "ground_air_mission",
        ):
            self.assertNotIn(forbidden, text)

    def test_fastlio_pipeline_is_shared_only_by_mapping_and_relocalization(self):
        common = self.launch_text("fastlio_pipeline.launch")
        mapping = self.launch_text("mapping_system.launch")
        relocalization = self.launch_text("relocalization_system.launch")
        task = self.launch_text("task_system.launch")

        self.assertIn("$(find fast_lio_open3d)/launch/mapping_mid360.launch", common)
        self.assertIn('type="fastlio_odometry_adapter.py"', common)
        include = "$(find car_bringup)/launch/fastlio_pipeline.launch"
        self.assertIn(include, mapping)
        self.assertIn(include, relocalization)
        self.assertNotIn(include, task)

    def test_mapping_owns_mapping_only_nodes(self):
        text = self.launch_text("mapping_system.launch")
        self.assertIn("$(find pcl_test)/launch/filter_ground.launch", text)
        self.assertIn("$(find dynamic_mapping)/launch/dynamic_mapping.launch", text)
        self.assertIn("$(find ground_air_mapping)/launch/mapping.launch", text)
        self.assertIn("$(find lukong_fusion_client)/launch/lukong_fusion_client.launch", text)
        self.assertNotIn("ground_air_localization)/launch/localization.launch", text)
        self.assertNotIn("teb_local_planner_tutorials", text)
        self.assertNotIn("ground_air_mission", text)

    def test_relocalization_owns_localization_without_mapping_or_motion(self):
        text = self.launch_text("relocalization_system.launch")
        self.assertIn("$(find ground_air_localization)/launch/localization.launch", text)
        for forbidden in (
            "filter_ground.launch",
            "dynamic_mapping.launch",
            "ground_air_mapping",
            "teb_local_planner_tutorials",
            "ground_air_control",
            "ground_air_mission",
        ):
            self.assertNotIn(forbidden, text)

    def test_task_owns_navigation_control_mission_and_optional_ccs(self):
        text = self.launch_text("task_system.launch")
        self.assertIn("$(find teb_local_planner_tutorials)/launch/bz_navigation.launch", text)
        self.assertIn("$(find ground_air_control)/launch/control.launch", text)
        self.assertIn("$(find ground_air_mission)/launch/mission.launch", text)
        self.assertIn("$(find epaguav_ground_air_task_adapter)/launch/task_adapter.launch", text)
        self.assertIn('name="start_ccs_task_adapter" default="false"', text)
        for forbidden in (
            "fast_lio_open3d",
            "filter_ground.launch",
            "dynamic_mapping.launch",
            "ground_air_mapping",
            "ground_air_localization",
        ):
            self.assertNotIn(forbidden, text)

    def test_base_owns_lower_static_tf_without_duplicates(self):
        base = self.launch_text("base_system.launch")
        mapping = (SRC / "ground_air_mapping" / "launch" / "mapping.launch").read_text(encoding="utf-8")
        localization = (SRC / "ground_air_localization" / "launch" / "localization.launch").read_text(encoding="utf-8")
        ground_filter = (SRC / "lidar_ground_filter" / "launch" / "filter_ground.launch").read_text(encoding="utf-8")

        self.assertEqual(base.count('name="odom_camera_init_broadcaster"'), 1)
        self.assertEqual(base.count('name="base_link_body_broadcaster"'), 1)
        self.assertNotIn("odom_camera_init_broadcaster", mapping)
        self.assertNotIn("odom_camera_init_broadcaster", localization)
        self.assertNotIn("base_link_body_broadcaster", ground_filter)

    def test_manifest_declares_new_runtime_launch_dependencies(self):
        manifest = (ROOT / "package.xml").read_text(encoding="utf-8")
        self.assertIn("<exec_depend>tf2_ros</exec_depend>", manifest)
        self.assertIn("<exec_depend>epaguav_ground_air_task_adapter</exec_depend>", manifest)


if __name__ == "__main__":
    unittest.main()
