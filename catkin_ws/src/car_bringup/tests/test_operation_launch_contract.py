#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT.parent


class OperationLaunchContractTests(unittest.TestCase):
    def launch_text(self, name):
        path = ROOT / "launch" / name
        self.assertTrue(path.is_file(), "missing launch file: {}".format(name))
        return path.read_text(encoding="utf-8")

    def test_start_mapping_launch_starts_mapping_layer_and_recording(self):
        text = self.launch_text("start_mapping.launch")
        self.assertIn('name="map_id"', text)
        self.assertIn('name="start_stack" default="true"', text)
        self.assertIn('$(find car_bringup)/launch/mapping_system.launch', text)
        self.assertNotIn("base_system.launch", text)
        self.assertIn('value="start_mapping"', text)

    def test_save_mapping_launch_is_one_shot(self):
        text = self.launch_text("save_mapping.launch")
        self.assertIn('value="save_mapping"', text)
        self.assertNotIn("manual_mapping.launch", text)
        self.assertNotIn("autonomy.launch", text)

    def test_relocalization_launch_starts_relocalization_layer_without_motion(self):
        text = self.launch_text("start_relocalization.launch")
        self.assertIn('name="map_id"', text)
        self.assertIn('$(find car_bringup)/launch/relocalization_system.launch', text)
        self.assertNotIn("base_system.launch", text)
        self.assertNotIn("task_system.launch", text)
        self.assertIn('value="relocalize"', text)

    def test_removed_platform_package_has_no_runtime_reference(self):
        self.assertFalse((SRC / "spiritwing_web").exists())
        for launch in (ROOT / "launch").glob("*.launch"):
            self.assertNotIn("spiritwing_web", launch.read_text(encoding="utf-8"))


if __name__ == "__main__":
    unittest.main()
