#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class MappingPackageContractTests(unittest.TestCase):
    def test_package_contains_recorder_launch_and_voxel_core(self):
        for relative in (
            "package.xml",
            "CMakeLists.txt",
            "launch/mapping.launch",
            "src/map_recorder_node.cpp",
            "include/ground_air_mapping/voxel_accumulator.hpp",
            "include/ground_air_mapping/static_map_filter.hpp",
            "config/pointcloud_preprocessing.yaml",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_recorder_exposes_typed_services_and_status(self):
        source = (ROOT / "src/map_recorder_node.cpp").read_text(encoding="utf-8")
        for token in (
            '"/ground_air/mapping/start"',
            '"/ground_air/mapping/save"',
            '"/ground_air/mapping/cancel"',
            '"/ground_air/mapping/status"',
            '"/cloud_registered"',
            '"/Odometry"',
            '"/map"',
            '"/ground_air/mapping/static_cloud"',
        ):
            self.assertIn(token, source)

    def test_bundle_is_canonical_atomic_and_non_overwriting(self):
        source = (ROOT / "src/map_recorder_node.cpp").read_text(encoding="utf-8")
        for token in (
            '"cloud_map.pcd"',
            '"map.pgm"',
            '"map.yaml"',
            '"metadata.json"',
            ".staging-",
            "rename(",
            "destination already exists",
            "^[A-Za-z0-9][A-Za-z0-9_.-]{0,63}$",
        ):
            self.assertIn(token, source)

    def test_saved_pcd_comes_from_removable_static_filter(self):
        source = (ROOT / "src/map_recorder_node.cpp").read_text(encoding="utf-8")
        self.assertIn("map_filter_->updateScan", source)
        self.assertIn("points = map_filter_->points()", source)
        self.assertIn("map_filter_->clear()", source)
        self.assertNotIn("accumulator_.add", source)

    def test_mapping_launch_defaults_to_safe_limits(self):
        launch = (ROOT / "launch/mapping.launch").read_text(encoding="utf-8")
        config = (ROOT / "config/pointcloud_preprocessing.yaml").read_text(
            encoding="utf-8"
        )
        self.assertIn('name="voxel_size" default="0.10"', launch)
        self.assertIn('name="max_voxels" default="5000000"', launch)
        self.assertIn('name="maps_root" default="/home/bitcq/catkin_ws/maps"', launch)
        self.assertIn("pointcloud_preprocessing.yaml", launch)
        for token in (
            "scan_voxel_size: 0.05",
            "radius: 0.15",
            "min_neighbors: 2",
            "temporal_voxel_size: 0.20",
            "min_hit_scans: 8",
            "min_observation_span: 2.0",
            "ray_stride: 4",
            "max_clearing_range: 20.0",
            "self_filter_enable: false",
        ):
            self.assertIn(token, config)

    def test_navigation_source_is_not_replaced_by_static_mapping_cloud(self):
        workspace_src = ROOT.parent
        config = (
            workspace_src
            / "teb_local_planner_tutorials/cfg/diff_drive/costmap_common_params_local.yaml"
        )
        if config.is_file():
            text = config.read_text(encoding="utf-8")
            self.assertIn("/cloud_registered_body", text)
            self.assertNotIn("/ground_air/mapping/static_cloud", text)

    def test_localization_source_is_not_replaced_by_static_mapping_cloud(self):
        workspace_src = ROOT.parent
        localization = workspace_src / "ground_air_localization"
        if localization.is_dir():
            text = "\n".join(
                path.read_text(encoding="utf-8", errors="ignore")
                for path in localization.rglob("*")
                if path.is_file()
            )
            self.assertIn("/cloud_registered", text)
            self.assertNotIn("/ground_air/mapping/static_cloud", text)


if __name__ == "__main__":
    unittest.main()
