#!/usr/bin/env python3
import ast
import sys
from pathlib import Path
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from ground_actuator_node import GroundActuatorPolicy  # noqa: E402


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

    def test_actuator_bundles_forward_and_yaw_in_one_publish(self):
        source = (SCRIPTS / "ground_actuator_node.py").read_text(encoding="utf-8")
        timer = find_method(
            ast.parse(source), "GroundActuatorNode", "_timer"
        )
        assignments = {}
        for node in ast.walk(timer):
            if not isinstance(node, ast.Assign) or not node.targets:
                continue
            target = node.targets[0]
            if not (
                isinstance(target, ast.Subscript)
                and isinstance(target.value, ast.Attribute)
                and target.value.attr == "controls"
            ):
                continue
            index = target.slice
            if isinstance(index, ast.Index):
                index = index.value
            if isinstance(index, (ast.Num, ast.Constant)):
                value = getattr(index, "n", getattr(index, "value", None))
                assignments[value] = node.lineno
        publishes = [
            node.lineno
            for node in ast.walk(timer)
            if isinstance(node, ast.Call)
            and isinstance(node.func, ast.Attribute)
            and node.func.attr == "publish"
        ]
        self.assertEqual(len(publishes), 1)
        self.assertLess(assignments[2], publishes[0])
        self.assertLess(assignments[3], publishes[0])


if __name__ == "__main__":
    unittest.main()
