#!/usr/bin/env python3
from pathlib import Path
import os
import subprocess
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]


class LocalizationRosContractTests(unittest.TestCase):
    def test_map_manager_exposes_typed_load_service_and_map_server(self):
        text = (ROOT / "scripts" / "map_manager_node.py").read_text(encoding="utf-8")
        self.assertIn("/ground_air/load_map", text)
        self.assertIn("LoadMap", text)
        self.assertIn('"map_server"', text)
        self.assertNotIn('Publisher("/ground_air/localization/valid"', text)
        self.assertIn("rospy.Publisher", text)
        self.assertIn('"/ground_air/localization/map_changed"', text)
        self.assertIn("self._map_changed_pub.publish", text)

    def test_global_relocalizer_uses_fpfh_ransac_then_icp_and_quality_gate(self):
        text = (ROOT / "src" / "global_relocalizer_node.cpp").read_text(encoding="utf-8")
        for token in (
            "ComputeFPFHFeature",
            "RegistrationRANSACBasedOnFeatureMatching",
            "RegistrationICP",
            "EvaluateRegistration",
            "min_fitness_",
            "max_rmse_",
            "required_confirmations_",
        ):
            self.assertIn(token, text)
        self.assertIn("/ground_air/relocalize", text)
        self.assertIn("/ground_air/active_map_pcd", text)
        self.assertIn("reference_map_filename_", text)
        self.assertIn('"cloud_map.pcd"', text)
        self.assertIn("active point-cloud map must be the processed", text)
        self.assertIn("/ground_air/localized", text)
        self.assertIn("submap_duration_", text)
        self.assertIn("min_submap_frames_", text)
        self.assertIn("/ground_air/localization/rmse", text)
        self.assertIn("/ground_air/localization/map_to_odom", text)
        self.assertIn("active_map_path != map_.path", text)
        self.assertIn('subscribe("/ground_air/localization/map_changed"', text)
        self.assertIn("mapChangedCallback", text)
        self.assertIn("request.use_initial_guess\n                ? icp", text)
        self.assertNotIn("sendTransform", text)

    def test_world_tf_has_one_dedicated_authority(self):
        script = (ROOT / "scripts" / "world_tf_owner_node.py").read_text(encoding="utf-8")
        for token in (
            '"~mode"',
            '"mapping"',
            '"localization"',
            '"/ground_air/localization/map_to_odom"',
            '"/ground_air/localization/valid"',
            "sendTransform",
            'child_frame_id = self._odom_frame',
        ):
            self.assertIn(token, script)
        self.assertIn("if self._mode == \"mapping\"", script)

    def test_localization_launch_uses_tf_owner_and_sixty_second_default(self):
        launch = (ROOT / "launch" / "localization.launch").read_text(encoding="utf-8")
        self.assertIn('name="relocalize_timeout" default="60.0"', launch)
        self.assertIn('type="world_tf_owner_node.py"', launch)
        self.assertIn('name="ground_air_world_tf_owner"', launch)
        self.assertIn('value="localization"', launch)

    def test_relocalizer_separates_scan_frame_from_output_odom_frame(self):
        launch = (ROOT / "launch" / "localization.launch").read_text(encoding="utf-8")
        source = (ROOT / "src" / "global_relocalizer_node.cpp").read_text(encoding="utf-8")
        self.assertIn('name="map_frame" default="map"', launch)
        self.assertIn('name="odom_frame" default="odom"', launch)
        self.assertIn('name="scan_frame" default="camera_init"', launch)
        self.assertIn('name="scan_frame" value="$(arg scan_frame)"', launch)
        self.assertIn('name="reference_map_filename" default="cloud_map.pcd"', launch)
        self.assertIn('name="reference_map_filename" value="$(arg reference_map_filename)"', launch)
        self.assertIn('"scan_frame", scan_frame_, "camera_init"', source)
        self.assertIn("latest_scan_frame_ != scan_frame_", source)

    def test_open3d_location_is_configurable_not_hardcoded(self):
        text = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
        self.assertIn("find_package(Open3D 0.14.1 REQUIRED)", text)
        self.assertNotIn("/home/bitcq/Downloads", text)

    def test_map_registry_is_importable_from_devel_python_path(self):
        completed = subprocess.run(
            [
                sys.executable,
                "-c",
                (
                    "from ground_air_localization.map_registry "
                    "import MapRegistry, MapRegistryError"
                ),
            ],
            cwd="/tmp",
            env=os.environ.copy(),
            capture_output=True,
            text=True,
        )
        self.assertEqual(0, completed.returncode, completed.stderr)


if __name__ == "__main__":
    unittest.main()
