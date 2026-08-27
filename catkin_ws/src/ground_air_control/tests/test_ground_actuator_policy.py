#!/usr/bin/env python3
import sys
from pathlib import Path
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from ground_actuator_node import GroundActuatorPolicy  # noqa: E402


class GroundActuatorPolicyTests(unittest.TestCase):
    def test_normalizes_and_clamps_motion(self):
        policy = GroundActuatorPolicy(max_linear=3.2, max_angular=5.0, timeout=0.5)
        policy.accept(linear=6.4, angular=10.0, now=1.0)
        self.assertEqual(policy.controls(1.1), (1.0, -1.0))

    def test_preserves_conservative_cmd_vel_as_px4_control(self):
        policy = GroundActuatorPolicy(max_linear=3.2, max_angular=5.0, timeout=0.5)
        policy.accept(linear=0.1, angular=0.1, now=1.0)
        self.assertEqual(policy.controls(1.1), (0.1, -0.1))

    def test_stale_command_is_zero(self):
        policy = GroundActuatorPolicy(max_linear=3.2, max_angular=5.0, timeout=0.5)
        policy.accept(linear=1.0, angular=1.0, now=1.0)
        self.assertEqual(policy.controls(1.6), (0.0, 0.0))


if __name__ == "__main__":
    unittest.main()
