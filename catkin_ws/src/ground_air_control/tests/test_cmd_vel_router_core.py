#!/usr/bin/env python3
import sys
from pathlib import Path
import unittest


SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))

from cmd_vel_router_core import CmdVelRouterCore  # noqa: E402


class CmdVelRouterCoreTests(unittest.TestCase):
    def test_ground_routing_requires_operator_selected_offboard(self):
        core = CmdVelRouterCore(timeout=0.5)
        core.set_vehicle_state("ground", "POSCTL")
        self.assertEqual(core.accept((0.2, 0.0, 0.0), 1.0).channel, "stop")
        core.set_vehicle_state("ground", "OFFBOARD")
        self.assertEqual(core.accept((0.2, 0.0, 0.0), 1.1).channel, "ground")

    def setUp(self):
        self.router = CmdVelRouterCore(timeout=0.5)

    def test_ground_mode_routes_only_to_ground(self):
        self.router.set_mode("ground")
        decision = self.router.accept((0.2, 0.1, 0.3), now=1.0)
        self.assertEqual(decision.channel, "ground")
        self.assertEqual(decision.command, (0.2, 0.0, 0.3))

    def test_airborne_mode_routes_only_to_air(self):
        self.router.set_mode("airborne")
        decision = self.router.accept((0.2, 0.1, 0.3), now=1.0)
        self.assertEqual(decision.channel, "air")
        self.assertEqual(decision.command, (0.2, 0.1, 0.3))

    def test_transition_state_suppresses_motion(self):
        self.router.set_mode("takeoff")
        decision = self.router.accept((0.2, 0.0, 0.0), now=1.0)
        self.assertEqual(decision.channel, "stop")
        self.assertEqual(decision.command, (0.0, 0.0, 0.0))

    def test_timeout_generates_repeated_stop(self):
        self.router.set_mode("ground")
        self.router.accept((0.2, 0.0, 0.0), now=1.0)
        self.assertEqual(self.router.tick(1.4).channel, "ground")
        stop = self.router.tick(1.6)
        self.assertEqual(stop.channel, "stop")

    def test_estop_latches_and_rejects_future_commands(self):
        self.router.set_mode("airborne")
        self.router.set_emergency_stop(True)
        self.assertEqual(self.router.accept((0.2, 0.0, 0.0), 1.0).channel, "stop")
        self.router.set_mode("ground")
        self.assertEqual(self.router.accept((0.2, 0.0, 0.0), 1.1).channel, "stop")
        self.router.set_emergency_stop(False)
        self.assertEqual(self.router.accept((0.2, 0.0, 0.0), 1.2).channel, "ground")


if __name__ == "__main__":
    unittest.main()
