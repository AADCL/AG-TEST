#!/usr/bin/env python3
import sys
from pathlib import Path
from types import SimpleNamespace
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from px4_backend import Px4TransitionPolicy  # noqa: E402


class Px4TransitionPolicyTests(unittest.TestCase):
    def setUp(self):
        self.policy = Px4TransitionPolicy(
            command=183,
            selector_channel=8,
            ground_pwm=1300,
            air_pwm=1700,
            confirmations_required=3,
        )

    def test_truthy_response_without_success_is_rejected(self):
        response = SimpleNamespace(success=False, result=1)
        self.assertFalse(self.policy.response_accepted(response))

    def test_flight_mode_requires_mode_sent_acknowledgement(self):
        self.assertTrue(
            self.policy.flight_mode_response_accepted(
                SimpleNamespace(mode_sent=True)
            )
        )
        self.assertFalse(
            self.policy.flight_mode_response_accepted(
                SimpleNamespace(mode_sent=False, success=True)
            )
        )

    def test_transition_command_is_version_independent_and_configurable(self):
        ground = self.policy.command_request("ground")
        air = self.policy.command_request("air")
        self.assertEqual(ground, (183, 8.0, 1300.0))
        self.assertEqual(air, (183, 8.0, 1700.0))

    def test_unknown_target_is_rejected(self):
        with self.assertRaises(ValueError):
            self.policy.command_request("fixed_wing")

    def test_feedback_must_be_stable_for_three_samples(self):
        self.policy.begin_observation("air")
        self.assertFalse(self.policy.observe_vtol_state(3))
        self.assertFalse(self.policy.observe_vtol_state(4))
        self.assertFalse(self.policy.observe_vtol_state(3))
        self.assertFalse(self.policy.observe_vtol_state(3))
        self.assertTrue(self.policy.observe_vtol_state(3))

    def test_takeoff_target_is_relative_to_current_altitude(self):
        self.assertAlmostEqual(self.policy.takeoff_target(2.35, 1.0), 3.35)
        with self.assertRaises(ValueError):
            self.policy.takeoff_target(0.0, 1.2)


if __name__ == "__main__":
    unittest.main()
