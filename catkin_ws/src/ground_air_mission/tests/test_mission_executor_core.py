#!/usr/bin/env python3
import sys
from pathlib import Path
import unittest


SOURCE = Path(__file__).resolve().parents[1] / "src"
sys.path.insert(0, str(SOURCE))

from ground_air_mission.mission_executor_core import (  # noqa: E402
    MissionError,
    MissionExecutorCore,
    MissionState,
)


class MissionExecutorCoreTests(unittest.TestCase):
    def setUp(self):
        self.core = MissionExecutorCore(dwell_seconds=2.0)
        self.goals = ["goal-0", "goal-1", "goal-2"]

    def test_submit_requires_localization_and_nonempty_goal_list(self):
        with self.assertRaises(MissionError):
            self.core.submit("m-1", [], localized=True, emergency_stop=False)
        with self.assertRaises(MissionError):
            self.core.submit("m-1", self.goals, localized=False, emergency_stop=False)
        with self.assertRaises(MissionError):
            self.core.submit("m-1", self.goals, localized=True, emergency_stop=True)

    def test_ordered_goals_each_have_two_second_dwell(self):
        self.core.submit("m-1", self.goals, localized=True, emergency_stop=False)
        self.assertEqual(self.core.start(), ("send_goal", "goal-0"))

        self.assertEqual(self.core.on_goal_succeeded(now=10.0, airborne=False), ("stop", None))
        self.assertEqual(self.core.state, MissionState.DWELLING)
        self.assertIsNone(self.core.tick(now=11.99, localized=True, emergency_stop=False))
        self.assertEqual(self.core.tick(now=12.0, localized=True, emergency_stop=False),
                         ("send_goal", "goal-1"))

        self.core.on_goal_succeeded(now=20.0, airborne=False)
        self.assertEqual(self.core.tick(22.0, True, False), ("send_goal", "goal-2"))
        self.core.on_goal_succeeded(now=30.0, airborne=False)
        self.assertEqual(self.core.tick(32.0, True, False), ("stop", None))
        self.assertEqual(self.core.state, MissionState.SUCCEEDED)

    def test_airborne_final_goal_waits_for_external_land_command(self):
        self.core.submit("m-air", ["last"], localized=True, emergency_stop=False)
        self.core.start()
        self.core.on_goal_succeeded(now=5.0, airborne=True)
        self.assertEqual(self.core.tick(7.0, True, False), ("hover", None))
        self.assertEqual(self.core.state, MissionState.WAITING_FOR_LAND)
        self.assertIsNone(self.core.tick(20.0, True, False))

    def test_pause_resume_during_navigation_resends_current_goal(self):
        self.core.submit("m-1", self.goals, localized=True, emergency_stop=False)
        self.core.start()
        self.assertEqual(self.core.pause(now=1.0), ("cancel_goal", None))
        self.assertEqual(self.core.state, MissionState.PAUSED)
        self.assertEqual(self.core.resume(now=2.0, localized=True, emergency_stop=False),
                         ("send_goal", "goal-0"))

    def test_pause_preserves_remaining_dwell_time(self):
        self.core.submit("m-1", self.goals, localized=True, emergency_stop=False)
        self.core.start()
        self.core.on_goal_succeeded(now=10.0, airborne=False)
        self.assertEqual(self.core.pause(now=10.5), ("stop", None))
        self.assertEqual(self.core.resume(20.0, True, False), ("stop", None))
        self.assertIsNone(self.core.tick(21.49, True, False))
        self.assertEqual(self.core.tick(21.5, True, False), ("send_goal", "goal-1"))

    def test_estop_or_localization_loss_cancels_active_goal_and_fails(self):
        self.core.submit("m-1", self.goals, localized=True, emergency_stop=False)
        self.core.start()
        self.assertEqual(self.core.tick(1.0, localized=False, emergency_stop=False),
                         ("cancel_and_stop", None))
        self.assertEqual(self.core.state, MissionState.FAILED)

        other = MissionExecutorCore(dwell_seconds=2.0)
        other.submit("m-2", self.goals, True, False)
        other.start()
        self.assertEqual(other.tick(1.0, localized=True, emergency_stop=True),
                         ("cancel_and_stop", None))
        self.assertEqual(other.state, MissionState.FAILED)

    def test_aborted_goal_fails_and_cancel_is_terminal(self):
        self.core.submit("m-1", self.goals, True, False)
        self.core.start()
        self.assertEqual(self.core.on_goal_failed("planner aborted"), ("stop", None))
        self.assertEqual(self.core.state, MissionState.FAILED)

        other = MissionExecutorCore()
        other.submit("m-2", self.goals, True, False)
        other.start()
        self.assertEqual(other.cancel(), ("cancel_and_stop", None))
        self.assertEqual(other.state, MissionState.CANCELED)

    def test_rejects_replacement_while_active(self):
        self.core.submit("m-1", self.goals, True, False)
        self.core.start()
        with self.assertRaises(MissionError):
            self.core.submit("m-2", ["new"], True, False)


if __name__ == "__main__":
    unittest.main()
