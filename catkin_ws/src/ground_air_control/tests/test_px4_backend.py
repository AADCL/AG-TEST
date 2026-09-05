#!/usr/bin/env python3
import ast
import sys
from pathlib import Path
from types import SimpleNamespace
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from px4_backend import Px4TransitionPolicy  # noqa: E402


def find_method(tree, class_name, method_name):
    cls = next(
        node
        for node in tree.body
        if isinstance(node, ast.ClassDef) and node.name == class_name
    )
    return next(
        node
        for node in cls.body
        if isinstance(node, ast.FunctionDef) and node.name == method_name
    )


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

    def test_takeoff_target_is_absolute_map_altitude(self):
        self.assertAlmostEqual(self.policy.takeoff_target(0.35, 1.4), 1.4)
        with self.assertRaises(ValueError):
            self.policy.takeoff_target(0.0, 0.0)

    def test_absolute_map_altitude_is_converted_to_px4_local_setpoint(self):
        self.assertAlmostEqual(
            self.policy.local_target_from_map(
                current_local_altitude=2.35,
                current_map_altitude=0.35,
                target_map_altitude=1.4,
            ),
            3.4,
        )

    def test_backend_uses_relocalized_map_pose_for_altitude_control(self):
        source = (SCRIPTS / "px4_backend.py").read_text(encoding="utf-8")
        self.assertIn('"/ground_air/localization/pose"', source)
        self.assertIn("local_target_from_map", source)
        self.assertIn('"local_altitude"', source)

    def test_ground_control_ready_requires_manual_armed_offboard_state(self):
        ready = {
            "connected": True,
            "physical_mode": "ground",
            "armed": True,
            "flight_mode": "OFFBOARD",
        }
        self.assertTrue(self.policy.ground_control_ready(ready))
        for key, value in (
            ("connected", False),
            ("physical_mode", "air"),
            ("armed", False),
            ("flight_mode", "POSCTL"),
        ):
            candidate = dict(ready)
            candidate[key] = value
            self.assertFalse(self.policy.ground_control_ready(candidate))

    def test_ground_prepare_does_not_command_arming_or_flight_mode(self):
        source = (SCRIPTS / "px4_backend.py").read_text(encoding="utf-8")
        tree = ast.parse(source)
        method = find_method(tree, "Px4Backend", "prepare_ground")
        calls = {
            getattr(node.func, "attr", "")
            for node in ast.walk(method)
            if isinstance(node, ast.Call)
        }
        self.assertIn("def disarm(self, timeout=", source)
        self.assertIn("self._arming(False)", source)
        self.assertFalse(
            {"_arming", "_set_mode", "switch_flight_mode", "disarm"} & calls
        )


if __name__ == "__main__":
    unittest.main()
