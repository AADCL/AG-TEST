#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
NODE = ROOT / "scripts" / "mission_executor_node.py"


class MissionNodeContractTests(unittest.TestCase):
    def test_ros_adapter_uses_move_base_action_and_typed_services(self):
        text = NODE.read_text(encoding="utf-8")
        self.assertIn("actionlib.SimpleActionClient", text)
        self.assertIn("MoveBaseAction", text)
        self.assertIn("SubmitMission", text)
        for service in ("submit", "start", "pause", "resume", "cancel"):
            self.assertIn('"/ground_air/mission/{}"'.format(service), text)

    def test_default_goal_frame_matches_navigation_stack(self):
        text = NODE.read_text(encoding="utf-8")
        self.assertIn('"~default_goal_frame", "map"', text)

    def test_status_and_vehicle_safety_topics_are_part_of_contract(self):
        text = NODE.read_text(encoding="utf-8")
        self.assertIn("/ground_air/vehicle_status", text)
        self.assertIn("/ground_air/mission/status", text)
        self.assertIn("/navigation/cmd_vel", text)

    def test_no_landing_service_is_called_by_mission_executor(self):
        text = NODE.read_text(encoding="utf-8").lower()
        self.assertNotIn("/ground_air/land", text)
        self.assertNotIn("command_tol", text)


if __name__ == "__main__":
    unittest.main()
