import math
import os
import sys
import unittest


SCRIPTS = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "scripts"))
sys.path.insert(0, SCRIPTS)

from drone_mode_control import (  # noqa: E402
    DroneModeController,
    body_to_world,
    quaternion_to_yaw,
)


class DroneModeControlTest(unittest.TestCase):
    def test_body_velocity_rotates_into_world_frame(self):
        vx, vy = body_to_world(1.0, 0.0, math.pi / 2.0)
        self.assertAlmostEqual(vx, 0.0, places=6)
        self.assertAlmostEqual(vy, 1.0, places=6)

    def test_quaternion_is_converted_to_yaw(self):
        half_angle = math.pi / 4.0
        yaw = quaternion_to_yaw(0.0, 0.0, math.sin(half_angle), math.cos(half_angle))
        self.assertAlmostEqual(yaw, math.pi / 2.0, places=6)

    def test_command_is_ignored_before_takeoff(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        self.assertFalse(core.accept_cmd_vel(0.5, 0.0, 0.2, 1.0))
        self.assertIsNone(core.compute_command(1.0, 0.0, 0.0))

    def test_airborne_command_is_limited_and_holds_altitude(self):
        core = DroneModeController(1.0, 0.4, 1.0, 0.5, 0.5)
        self.assertTrue(core.begin_takeoff())
        core.finish_takeoff(True, 2.0)
        self.assertTrue(core.accept_cmd_vel(3.0, 4.0, 1.0, 10.0))

        command = core.compute_command(10.1, 0.0, 1.0)

        self.assertAlmostEqual(math.hypot(command.vx, command.vy), 1.0)
        self.assertAlmostEqual(command.yaw_rate, 0.4)
        self.assertAlmostEqual(command.vz, 0.5)

    def test_timeout_stops_horizontal_and_yaw_but_keeps_altitude(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        core.begin_takeoff()
        core.finish_takeoff(True, 2.0)
        core.accept_cmd_vel(0.5, 0.2, 0.3, 10.0)

        command = core.compute_command(10.6, 0.0, 1.8)

        self.assertEqual((command.vx, command.vy, command.yaw_rate), (0.0, 0.0, 0.0))
        self.assertAlmostEqual(command.vz, 0.2)

    def test_failed_takeoff_returns_to_standby(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        core.begin_takeoff()
        core.finish_takeoff(False, 2.0)
        self.assertEqual(core.state, core.STANDBY)

    def test_failed_landing_returns_to_airborne_state(self):
        core = DroneModeController(1.0, 1.0, 1.0, 0.5, 0.5)
        core.begin_takeoff()
        core.finish_takeoff(True, 2.0)
        self.assertTrue(core.begin_landing())
        core.finish_landing(False)
        self.assertEqual(core.state, core.AIRBORNE)


if __name__ == "__main__":
    unittest.main()
