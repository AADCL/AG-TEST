#!/usr/bin/env python3
"""Contract tests for the restored upstream FAST-LIO topic names."""

from pathlib import Path
import unittest


SRC = Path(__file__).resolve().parents[2]

CANONICAL_TOPICS = (
    "/Laser_map",
    "/Odometry",
    "/cloud_effected",
    "/cloud_registered",
    "/cloud_registered_body",
)

LEGACY_TOPICS = (
    "/Laser_map_1",
    "/Odometry_loc",
    "/cloud_effected_1",
    "/cloud_registered_1",
    "/cloud_registered_body_1",
)

CONSUMER_FILES = (
    "teb_local_planner_tutorials/cfg/diff_drive/costmap_common_params_global.yaml",
    "teb_local_planner_tutorials/cfg/diff_drive/costmap_common_params_local.yaml",
    "teb_local_planner_tutorials/cfg/diff_drive/teb_local_planner_params.yaml",
    "ground_air_mapping/launch/mapping.launch",
    "ground_air_mapping/src/map_recorder_node.cpp",
    "ground_air_localization/launch/localization.launch",
    "ground_air_localization/src/global_relocalizer_node.cpp",
    "car_bringup/scripts/fastlio_odometry_adapter.py",
    "car_bringup/launch/ground_air_full.launch",
    "spiritwing_web/config/params.yaml",
    "spiritwing_web/config/params_back.yaml",
    "lukong_fusion_client/scripts/lukong_fusion_client_node.py",
    "lukong_fusion_client/config/lukong_fusion_client.yaml",
    "lidar_ground_filter/launch/filter_ground.launch",
)


class FastlioTopicContractTests(unittest.TestCase):
    def test_fastlio_publishes_upstream_topic_names(self):
        source = (SRC / "fast_lio_open3d/src/laserMapping.cpp").read_text(
            encoding="utf-8"
        )
        for topic in CANONICAL_TOPICS:
            self.assertIn(f'("{topic}", 100000)', source)
        for topic in LEGACY_TOPICS:
            self.assertNotIn(f'("{topic}", 100000)', source)

    def test_runtime_consumers_do_not_depend_on_legacy_names(self):
        for relative_path in CONSUMER_FILES:
            text = (SRC / relative_path).read_text(encoding="utf-8")
            for topic in LEGACY_TOPICS:
                self.assertNotIn(topic, text, f"{relative_path} still uses {topic}")

    def test_unrelated_control_and_visualization_topics_are_preserved(self):
        mode_manager = (SRC / "ground_air_control/scripts/mode_manager_node.py").read_text(
            encoding="utf-8"
        )
        vision_bridge = (SRC / "vision_to_mavros/src/vision_to_mavros.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn('"/air/cmd_vel"', mode_manager)
        self.assertIn('"body_frame/path"', vision_bridge)


if __name__ == "__main__":
    unittest.main()
