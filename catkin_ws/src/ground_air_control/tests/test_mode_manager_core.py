#!/usr/bin/env python3
import sys
from pathlib import Path
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from mode_manager_core import ModeManagerCore, Mode, TransitionError  # noqa: E402


class ModeManagerCoreTests(unittest.TestCase):
    def setUp(self):
        self.core = ModeManagerCore(takeoff_height=1.0, telemetry_timeout=0.5)
        self.core.update_telemetry(
            now=10.0,
            connected=True,
            armed=False,
            physical_mode="ground",
            altitude=0.0,
            pose_stamp=10.0,
        )

    def test_takeoff_height_is_exactly_one_metre(self):
        self.assertEqual(self.core.takeoff_height, 1.0)

    def test_air_transition_then_takeoff_requires_real_feedback(self):
        self.assertEqual(self.core.state, Mode.GROUND)
        self.core.begin_switch_to_air(now=10.1)
        self.assertEqual(self.core.state, Mode.SWITCHING_TO_AIR)

        with self.assertRaises(TransitionError):
            self.core.finish_switch_to_air(success=True)
        self.assertEqual(self.core.state, Mode.FAULT)

        self.setUp()
        self.core.begin_switch_to_air(now=10.1)
        self.core.update_telemetry(10.2, True, False, "air", 0.0, 10.2)
        self.core.finish_switch_to_air(success=True)
        self.assertEqual(self.core.state, Mode.AIR_READY)

        self.core.begin_takeoff(now=10.3)
        self.assertEqual(self.core.state, Mode.TAKEOFF)
        self.core.update_telemetry(10.4, True, True, "air", 0.95, 10.4)
        self.core.finish_takeoff(success=True)
        self.assertEqual(self.core.state, Mode.AIRBORNE)

    def test_takeoff_rejects_stale_pose(self):
        self.core.begin_switch_to_air(now=10.1)
        self.core.update_telemetry(10.2, True, False, "air", 0.0, 10.2)
        self.core.finish_switch_to_air(True)
        with self.assertRaises(TransitionError):
            self.core.begin_takeoff(now=11.0)

    def test_emergency_stop_is_latched_until_explicit_reset(self):
        self.core.set_emergency_stop(True, "operator")
        self.assertEqual(self.core.state, Mode.ESTOP)
        self.assertTrue(self.core.emergency_stop)
        with self.assertRaises(TransitionError):
            self.core.begin_switch_to_air(now=10.1)

        self.core.set_emergency_stop(False, "operator reset")
        self.assertFalse(self.core.emergency_stop)
        self.assertEqual(self.core.state, Mode.GROUND)

    def test_airborne_reset_returns_to_airborne_hover_state(self):
        self.core.update_telemetry(10.1, True, True, "air", 1.0, 10.1)
        self.core.synchronize_from_telemetry()
        self.core.set_emergency_stop(True, "operator")
        self.core.set_emergency_stop(False, "operator reset")
        self.assertEqual(self.core.state, Mode.AIRBORNE)

    def test_flight_goal_completion_never_starts_landing(self):
        self.core.update_telemetry(10.1, True, True, "air", 1.0, 10.1)
        self.core.synchronize_from_telemetry()
        action = self.core.on_navigation_goal_reached()
        self.assertEqual(action, "hover")
        self.assertEqual(self.core.state, Mode.AIRBORNE)

    def test_land_then_ground_switch_uses_observed_states(self):
        self.core.update_telemetry(10.1, True, True, "air", 1.0, 10.1)
        self.core.synchronize_from_telemetry()
        self.core.begin_landing(now=10.2)
        self.core.update_telemetry(10.3, True, False, "air", 0.05, 10.3)
        self.core.finish_landing(True)
        self.assertEqual(self.core.state, Mode.AIR_READY)
        self.core.begin_switch_to_ground(now=10.4)
        self.core.update_telemetry(10.5, True, False, "ground", 0.05, 10.5)
        self.core.finish_switch_to_ground(True)
        self.assertEqual(self.core.state, Mode.GROUND)


if __name__ == "__main__":
    unittest.main()
