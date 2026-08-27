#!/usr/bin/env python3
"""Regression tests for catkin devel-space Python imports."""

import subprocess
import sys
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class PythonPackageContractTests(unittest.TestCase):
    def test_core_is_importable_from_standard_source_package(self):
        result = subprocess.run(
            [
                sys.executable,
                "-c",
                (
                    "from ground_air_mission.mission_executor_core "
                    "import MissionExecutorCore; "
                    "assert MissionExecutorCore(dwell_seconds=2.0).dwell_seconds == 2.0"
                ),
            ],
            cwd=str(ROOT),
            env={"PYTHONPATH": str(ROOT / "src")},
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_catkin_declares_python_package_setup(self):
        cmake = (ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
        self.assertIn("catkin_python_setup()", cmake)
        self.assertTrue((ROOT / "setup.py").is_file())

    def test_ros_node_imports_core_through_package_namespace(self):
        node = (ROOT / "scripts" / "mission_executor_node.py").read_text(
            encoding="utf-8"
        )
        self.assertIn(
            "from ground_air_mission.mission_executor_core import", node
        )


if __name__ == "__main__":
    unittest.main()
