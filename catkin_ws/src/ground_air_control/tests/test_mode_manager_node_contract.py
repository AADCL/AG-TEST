#!/usr/bin/env python3
import ast
from pathlib import Path
import unittest


PACKAGE_ROOT = Path(__file__).resolve().parents[1]
NODE = PACKAGE_ROOT / "scripts" / "mode_manager_node.py"


class ModeManagerNodeContractTests(unittest.TestCase):
    def test_core_modules_are_installed_for_catkin_wrappers(self):
        cmake = (PACKAGE_ROOT / "CMakeLists.txt").read_text(encoding="utf-8")
        setup_path = PACKAGE_ROOT / "setup.py"
        self.assertTrue(setup_path.is_file())
        setup = setup_path.read_text(encoding="utf-8")
        self.assertIn("catkin_python_setup()", cmake)
        self.assertIn('packages=["ground_air_control"]', setup)
        for module in ("cmd_vel_router_core", "mode_manager_core", "px4_backend"):
            self.assertTrue(
                (PACKAGE_ROOT / "src" / "ground_air_control" / f"{module}.py").is_file()
            )

    def test_exposes_required_ros_services(self):
        source = NODE.read_text(encoding="utf-8")
        for name in (
            '"/ground_air/takeoff"',
            '"/ground_air/land"',
            '"/ground_air/set_mode"',
            '"/ground_air/emergency_stop"',
        ):
            self.assertIn(name, source)

    def test_constructor_does_not_switch_or_takeoff(self):
        tree = ast.parse(NODE.read_text(encoding="utf-8"))
        cls = next(node for node in tree.body if isinstance(node, ast.ClassDef))
        init = next(
            node for node in cls.body if isinstance(node, ast.FunctionDef) and node.name == "__init__"
        )
        calls = {
            getattr(node.func, "attr", "")
            for node in ast.walk(init)
            if isinstance(node, ast.Call)
        }
        self.assertFalse({"switch_physical_mode", "takeoff", "land"} & calls)

    def test_startup_latches_software_emergency_stop(self):
        source = NODE.read_text(encoding="utf-8")
        self.assertIn(
            'self.core.set_emergency_stop(True, "startup safety interlock")',
            source,
        )

    def test_ground_drive_uses_confirmed_offboard_lifecycle(self):
        source = NODE.read_text(encoding="utf-8")
        self.assertIn('"OFFBOARD", self.ground_mode_timeout', source)
        self.assertIn('"POSCTL", self.ground_mode_timeout', source)
        self.assertIn("rospy.sleep(self.ground_stop_settle_time)", source)

    def test_air_commands_use_fixed_altitude_controller(self):
        source = NODE.read_text(encoding="utf-8")
        self.assertIn("altitude_kp", source)
        self.assertIn("target_altitude", source)
        self.assertIn("backend.set_velocity", source)


if __name__ == "__main__":
    unittest.main()
