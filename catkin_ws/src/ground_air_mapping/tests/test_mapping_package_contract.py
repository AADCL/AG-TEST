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
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_recorder_exposes_typed_services_and_status(self):
        source = (ROOT / "src/map_recorder_node.cpp").read_text(encoding="utf-8")
        for token in (
            '"/ground_air/mapping/start"',
            '"/ground_air/mapping/save"',
            '"/ground_air/mapping/cancel"',
            '"/ground_air/mapping/status"',
            '"/cloud_registered_1"',
            '"/map"',
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

    def test_mapping_launch_defaults_to_safe_limits(self):
        launch = (ROOT / "launch/mapping.launch").read_text(encoding="utf-8")
        self.assertIn('name="voxel_size" default="0.10"', launch)
        self.assertIn('name="max_voxels" default="5000000"', launch)
        self.assertIn('name="maps_root" default="/home/bitcq/catkin_ws/maps"', launch)


if __name__ == "__main__":
    unittest.main()
