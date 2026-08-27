#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FullLaunchContractTests(unittest.TestCase):
    def test_full_launch_contains_all_supervised_stages(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8")
        for package in (
            "livox_ros_driver2",
            "fast_lio_open3d",
            "pcl_test",
            "ground_air_localization",
            "teb_local_planner_tutorials",
            "ground_air_control",
            "ground_air_mission",
            "spiritwing_web",
            "vision_to_mavros",
        ):
            self.assertIn("$(find {})".format(package), text)
        self.assertIn('name="start_video" default="false"', text)
        self.assertIn('name="start_mavros" default="false"', text)

    def test_startup_never_invokes_takeoff_land_or_arming(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8").lower()
        self.assertNotIn("/ground_air/takeoff", text)
        self.assertNotIn("/ground_air/land", text)
        self.assertNotIn("cmd/arming", text)

    def test_historical_map_tf_has_a_single_owner(self):
        text = (ROOT.parent / "lidar_ground_filter" / "launch" / "filter_ground.launch").read_text(encoding="utf-8")
        self.assertNotIn("odom_camera_init_broadcaster", text)
        self.assertNotIn("world_odom_broadcaster", text)

    def test_manual_mapping_disables_software_motion_and_starts_recorder(self):
        text = (ROOT / "launch" / "manual_mapping.launch").read_text(encoding="utf-8")
        self.assertIn('name="start_control" value="false"', text)
        self.assertIn('name="start_navigation" value="false"', text)
        self.assertIn('$(find ground_air_mapping)/launch/mapping.launch', text)

    def test_autonomy_can_start_localization_only_by_default(self):
        text = (ROOT / "launch" / "autonomy.launch").read_text(encoding="utf-8")
        self.assertIn('name="start_navigation" default="false"', text)
        self.assertIn('name="start_control" default="false"', text)
        self.assertIn('name="start_mission" default="false"', text)


if __name__ == "__main__":
    unittest.main()
