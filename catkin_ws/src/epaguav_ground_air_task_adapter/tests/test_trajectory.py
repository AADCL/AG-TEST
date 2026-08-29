import math
import os
import tempfile
import unittest

from epaguav_ground_air_task_adapter import trajectory


VALID_XML = """<?xml version='1.0' encoding='utf-8'?>
<trajectory schema_version="2" task_id="task-a" subtask_id="sub-a"
 device_id="AGV_001" revision="3" crc32="123">
  <metadata task_name="test" map_id="map-a" frame_id="map"
   cruise_speed_mps="0.5" start_delay_seconds="2.0" />
  <waypoints count="2">
    <waypoint index="0" waypoint_id="wp-0" x="1.0" y="0.0" z="0.0" />
    <waypoint index="1" waypoint_id="wp-1" x="1.0" y="2.0" z="0.0" />
  </waypoints>
</trajectory>
"""


class TrajectoryTests(unittest.TestCase):
    def _load(self, xml_text=VALID_XML, **overrides):
        root = tempfile.TemporaryDirectory()
        self.addCleanup(root.cleanup)
        path = os.path.join(root.name, "trajectory.xml")
        with open(path, "w", encoding="utf-8") as stream:
            stream.write(xml_text)
        arguments = {
            "task_id": "task-a",
            "subtask_id": "sub-a",
            "device_id": "AGV_001",
            "revision": 3,
            "map_id": "map-a",
            "frame_id": "map",
            "current_xy": (0.0, 0.0),
        }
        arguments.update(overrides)
        return trajectory.load_trajectory(path, root.name, **arguments)

    def test_loads_valid_ccs_xml_and_generates_segment_headings(self):
        self.assertTrue(hasattr(trajectory, "load_trajectory"))
        result = self._load()
        self.assertEqual(result.mission_id, "task-a:sub-a:r3")
        self.assertEqual(len(result.waypoints), 2)
        self.assertAlmostEqual(result.waypoints[0].yaw, 0.0)
        self.assertAlmostEqual(result.waypoints[1].yaw, math.pi / 2.0)

    def test_rejects_identity_frame_map_revision_and_count_mismatches(self):
        self.assertTrue(hasattr(trajectory, "AdapterError"))
        cases = [
            {"task_id": "other"},
            {"subtask_id": "other"},
            {"device_id": "other"},
            {"revision": 4},
            {"map_id": "other"},
            {"frame_id": "odom"},
        ]
        for overrides in cases:
            with self.subTest(overrides=overrides):
                with self.assertRaises(trajectory.AdapterError) as raised:
                    self._load(**overrides)
                self.assertEqual(raised.exception.error_code, "INVALID_TRAJECTORY")
        one_point = VALID_XML.replace('count="2"', 'count="1"').replace(
            '    <waypoint index="1" waypoint_id="wp-1" x="1.0" y="2.0" z="0.0" />\n',
            "",
        )
        with self.assertRaises(trajectory.AdapterError):
            self._load(one_point)

    def test_rejects_nonfinite_coordinates_and_noncontiguous_indices(self):
        self.assertTrue(hasattr(trajectory, "AdapterError"))
        for xml_text in (
            VALID_XML.replace('x="1.0"', 'x="nan"', 1),
            VALID_XML.replace('index="1"', 'index="2"'),
            VALID_XML.replace('waypoint_id="wp-1"', 'waypoint_id="wp-0"'),
        ):
            with self.assertRaises(trajectory.AdapterError):
                self._load(xml_text)

    def test_rejects_paths_outside_mission_root_and_symbolic_links(self):
        self.assertTrue(hasattr(trajectory, "AdapterError"))
        with tempfile.TemporaryDirectory() as mission_root, tempfile.TemporaryDirectory() as outside:
            outside_path = os.path.join(outside, "trajectory.xml")
            with open(outside_path, "w", encoding="utf-8") as stream:
                stream.write(VALID_XML)
            arguments = dict(
                task_id="task-a", subtask_id="sub-a", device_id="AGV_001",
                revision=3, map_id="map-a", frame_id="map", current_xy=(0.0, 0.0),
            )
            with self.assertRaises(trajectory.AdapterError):
                trajectory.load_trajectory(outside_path, mission_root, **arguments)
            link_path = os.path.join(mission_root, "trajectory.xml")
            os.symlink(outside_path, link_path)
            with self.assertRaises(trajectory.AdapterError):
                trajectory.load_trajectory(link_path, mission_root, **arguments)

    def test_coincident_points_keep_the_last_defined_heading(self):
        xml_text = VALID_XML.replace('x="1.0" y="2.0"', 'x="1.0" y="0.0"')
        result = self._load(xml_text)
        self.assertAlmostEqual(result.waypoints[0].yaw, 0.0)
        self.assertAlmostEqual(result.waypoints[1].yaw, 0.0)


if __name__ == "__main__":
    unittest.main()
