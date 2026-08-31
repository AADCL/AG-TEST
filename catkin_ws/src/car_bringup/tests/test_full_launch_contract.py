#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class FullLaunchContractTests(unittest.TestCase):
    def test_full_launch_is_a_documented_compatibility_wrapper(self):
        text = (ROOT / "launch" / "ground_air_full.launch").read_text(encoding="utf-8")
        self.assertIn("兼容", text)
        self.assertIn("$(find car_bringup)/launch/base_system.launch", text)
        self.assertIn("$(find car_bringup)/launch/relocalization_system.launch", text)
        self.assertIn("$(find car_bringup)/launch/task_system.launch", text)
        self.assertNotIn("spiritwing_web", text)

    def test_startup_never_invokes_takeoff_land_or_arming(self):
        for name in ("base_system.launch", "mapping_system.launch", "relocalization_system.launch", "task_system.launch"):
            text = (ROOT / "launch" / name).read_text(encoding="utf-8").lower()
            self.assertNotIn("/ground_air/takeoff", text)
            self.assertNotIn("/ground_air/land", text)
            self.assertNotIn("cmd/arming", text)

    def test_localization_owns_map_odom_and_base_owns_static_alignment(self):
        text = (ROOT.parent / "ground_air_localization" / "launch" / "localization.launch").read_text(encoding="utf-8")
        base = (ROOT / "launch" / "base_system.launch").read_text(encoding="utf-8")
        self.assertIn('name="map_frame" default="map"', text)
        self.assertIn('name="odom_frame" default="odom"', text)
        self.assertNotIn('name="odom_camera_init_broadcaster"', text)
        self.assertIn('name="odom_camera_init_broadcaster"', base)
        self.assertIn('$(arg odom_frame) $(arg camera_init_frame)', base)

    def test_active_launches_remove_livox_frame(self):
        base = (ROOT / "launch" / "base_system.launch").read_text(encoding="utf-8")
        ground_filter = (ROOT.parent / "lidar_ground_filter" / "launch" / "filter_ground.launch").read_text(encoding="utf-8")
        dynamic_mapping = (ROOT.parent / "dynamic_mapping" / "launch" / "dynamic_mapping.launch").read_text(encoding="utf-8")
        livox = (ROOT.parent / "livox_ros_driver2" / "launch_ROS1" / "msg_MID360.launch").read_text(encoding="utf-8")
        for text in (base, ground_filter, dynamic_mapping, livox):
            self.assertNotIn('value="livox_frame"', text)
            self.assertNotIn('default="livox_frame"', text)
        self.assertIn('name="msg_frame_id" value="$(arg base_frame)"', base)
        self.assertIn('name="msg_frame_id" default="base_link"', livox)
        self.assertIn('name="lidar_frame_id" value="base_link"', dynamic_mapping)

    def test_navigation_uses_map_as_global_frame(self):
        task = (ROOT / "launch" / "task_system.launch").read_text(encoding="utf-8")
        mission = (ROOT.parent / "ground_air_mission" / "launch" / "mission.launch").read_text(encoding="utf-8")
        global_costmap = (ROOT.parent / "teb_local_planner_tutorials" / "cfg" / "diff_drive" / "global_costmap_params.yaml").read_text(encoding="utf-8")
        local_costmap = (ROOT.parent / "teb_local_planner_tutorials" / "cfg" / "diff_drive" / "local_costmap_params.yaml").read_text(encoding="utf-8")
        self.assertIn('name="goal_frame" default="map"', task)
        self.assertIn('name="goal_frame" value="$(arg goal_frame)"', task)
        self.assertIn('name="goal_frame" default="map"', mission)
        self.assertIn("global_frame: map", global_costmap)
        self.assertIn("global_frame: map", local_costmap)

    def test_manual_mapping_disables_software_motion_and_starts_recorder(self):
        text = (ROOT / "launch" / "manual_mapping.launch").read_text(encoding="utf-8")
        self.assertIn('$(find car_bringup)/launch/mapping_system.launch', text)
        self.assertNotIn('file="$(find car_bringup)/launch/base_system.launch"', text)
        self.assertNotIn("task_system.launch", text)

    def test_autonomy_can_start_localization_only_by_default(self):
        text = (ROOT / "launch" / "autonomy.launch").read_text(encoding="utf-8")
        self.assertIn('$(find car_bringup)/launch/relocalization_system.launch', text)
        self.assertIn('name="start_task" default="false"', text)
        self.assertIn('if="$(arg start_task)" file="$(find car_bringup)/launch/task_system.launch"', text)

    def test_ccs_task_adapter_is_opt_in_and_passed_through_autonomy(self):
        task = (ROOT / "launch" / "task_system.launch").read_text(encoding="utf-8")
        autonomy = (ROOT / "launch" / "autonomy.launch").read_text(encoding="utf-8")
        self.assertIn('name="start_ccs_task_adapter" default="false"', task)
        self.assertIn(
            'if="$(arg start_ccs_task_adapter)" file="$(find epaguav_ground_air_task_adapter)/launch/task_adapter.launch"',
            task,
        )
        self.assertIn('name="ccs_mission_root" default="/home/bitcq/ccs_edge_ws/mission"', task)
        self.assertIn('name="start_ccs_task_adapter" default="false"', autonomy)
        self.assertIn('name="start_ccs_task_adapter" value="$(arg start_ccs_task_adapter)"', autonomy)
        self.assertIn('name="ccs_mission_root" value="$(arg ccs_mission_root)"', autonomy)


if __name__ == "__main__":
    unittest.main()
