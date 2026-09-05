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

    def test_takeoff_height_is_task_configurable_within_safety_limits(self):
        self.core.set_takeoff_height(1.7)
        self.assertEqual(self.core.takeoff_height, 1.7)
        with self.assertRaises(ValueError):
            self.core.set_takeoff_height(3.5)

    def test_airborne_vehicle_accepts_a_new_flight_altitude_target(self):
        self.core.update_telemetry(10.1, True, True, "air", 1.0, 10.1)
        self.core.synchronize_from_telemetry()
        self.assertEqual(self.core.set_flight_target(10.2, 1.8), 1.8)
        self.assertIn("1.80 m", self.core.detail)

        self.core.update_telemetry(10.3, True, False, "ground", 0.0, 10.3)
        self.core.synchronize_from_telemetry()
        with self.assertRaises(TransitionError):
            self.core.set_flight_target(10.4, 1.2)

    def test_takeoff_entry_accepts_ground_or_already_air_ready(self):
        self.assertTrue(hasattr(self.core, "takeoff_requires_air_switch"))
        self.core.update_telemetry(10.0, True, False, "ground", 0.0, 10.0)
        self.assertTrue(self.core.takeoff_requires_air_switch(10.1))

        ready = ModeManagerCore(takeoff_height=1.0, telemetry_timeout=0.5)
        ready.update_telemetry(10.0, True, False, "air", 0.0, 10.0)
        self.assertFalse(ready.takeoff_requires_air_switch(10.1))

    def test_ground_takeoff_preparation_reports_whether_disarm_is_required(self):
        self.core.update_telemetry(10.0, True, True, "ground", 0.0, 10.0)
        self.assertTrue(self.core.ground_disarm_required_for_takeoff(10.1))
        self.core.update_telemetry(10.2, True, False, "ground", 0.0, 10.2)
        self.assertFalse(self.core.ground_disarm_required_for_takeoff(10.3))

    def test_ground_navigation_ready_requires_confirmed_ground_offboard(self):
        self.core.begin_ground_navigation(10.1)
        with self.assertRaises(TransitionError):
            self.core.finish_ground_navigation(False, "POSCTL")
        self.setUp()
        self.core.begin_ground_navigation(10.1)
        self.core.update_telemetry(10.2, True, True, "ground", 0.0, 10.2)
        self.core.finish_ground_navigation(True, "OFFBOARD")
        self.assertEqual(self.core.state, Mode.GROUND)
        self.assertEqual(self.core.detail, "ground navigation ready")

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
