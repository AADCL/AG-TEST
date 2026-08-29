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
            "vision_to_mavros",
        ):
            self.assertIn("$(find {})".format(package), text)
        self.assertIn('name="start_mavros" default="false"', text)
        self.assertNotIn("spiritwing_web", text)

    def test_startup_never_invokes_takeoff_land_or_arming(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8").lower()
        self.assertNotIn("/ground_air/takeoff", text)
        self.assertNotIn("/ground_air/land", text)
        self.assertNotIn("cmd/arming", text)

    def test_localization_owns_map_odom_and_static_camera_alignment(self):
        text = (ROOT.parent / "ground_air_localization" / "launch" / "localization.launch").read_text(encoding="utf-8")
        self.assertIn('name="map_frame" default="map"', text)
        self.assertIn('name="odom_frame" default="odom"', text)
        self.assertIn('name="camera_init_frame" default="camera_init"', text)
        self.assertIn('name="odom_camera_init_broadcaster"', text)
        self.assertIn('$(arg odom_frame) $(arg camera_init_frame)', text)

    def test_active_launches_remove_livox_frame(self):
        full = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8")
        ground_filter = (ROOT.parent / "lidar_ground_filter" / "launch" / "filter_ground.launch").read_text(encoding="utf-8")
        dynamic_mapping = (ROOT.parent / "dynamic_mapping" / "launch" / "dynamic_mapping.launch").read_text(encoding="utf-8")
        livox = (ROOT.parent / "livox_ros_driver2" / "launch_ROS1" / "msg_MID360.launch").read_text(encoding="utf-8")
        for text in (full, ground_filter, dynamic_mapping, livox):
            self.assertNotIn("livox_frame", text)
        self.assertIn('name="msg_frame_id" value="base_link"', full)
        self.assertIn('name="msg_frame_id" default="base_link"', livox)
        self.assertIn('name="lidar_frame_id" value="base_link"', dynamic_mapping)

    def test_navigation_uses_map_as_global_frame(self):
        full = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8")
        mission = (ROOT.parent / "ground_air_mission" / "launch" / "mission.launch").read_text(encoding="utf-8")
        global_costmap = (ROOT.parent / "teb_local_planner_tutorials" / "cfg" / "diff_drive" / "global_costmap_params.yaml").read_text(encoding="utf-8")
        local_costmap = (ROOT.parent / "teb_local_planner_tutorials" / "cfg" / "diff_drive" / "local_costmap_params.yaml").read_text(encoding="utf-8")
        self.assertIn('name="goal_frame" value="map"', full)
        self.assertIn('name="target_frame_id" value="/map"', full)
        self.assertIn('name="goal_frame" default="map"', mission)
        self.assertIn("global_frame: map", global_costmap)
        self.assertIn("global_frame: map", local_costmap)

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

    def test_ccs_task_adapter_is_opt_in_and_passed_through_autonomy(self):
        full = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8")
        autonomy = (ROOT / "launch" / "autonomy.launch").read_text(encoding="utf-8")
        self.assertIn('name="start_ccs_task_adapter" default="false"', full)
        self.assertIn(
            'if="$(arg start_ccs_task_adapter)" file="$(find epaguav_ground_air_task_adapter)/launch/task_adapter.launch"',
            full,
        )
        self.assertIn('name="ccs_mission_root" default="/home/bitcq/ccs_edge_ws/mission"', full)
        self.assertIn('name="start_ccs_task_adapter" default="false"', autonomy)
        self.assertIn('name="start_ccs_task_adapter" value="$(arg start_ccs_task_adapter)"', autonomy)
        self.assertIn('name="ccs_mission_root" value="$(arg ccs_mission_root)"', autonomy)


if __name__ == "__main__":
    unittest.main()
