#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]
NODE = ROOT / "src" / "spiritwing_web_node.cpp"


class GroundAirIntegrationContractTests(unittest.TestCase):
    def setUp(self):
        self.text = NODE.read_text(encoding="utf-8")

    def test_web_commands_use_the_supervised_ground_air_services(self):
        for header in (
            "ground_air_msgs/LoadMap.h",
            "ground_air_msgs/SaveMapping.h",
            "ground_air_msgs/StartMapping.h",
            "ground_air_msgs/Relocalize.h",
            "ground_air_msgs/SetEmergencyStop.h",
            "ground_air_msgs/SubmitMission.h",
            "std_srvs/Trigger.h",
        ):
            self.assertIn(header, self.text)
        for service in (
            "/ground_air/load_map",
            "/ground_air/mapping/start",
            "/ground_air/mapping/save",
            "/ground_air/relocalize",
            "/ground_air/mission/submit",
            "/ground_air/mission/start",
            "/ground_air/mission/pause",
            "/ground_air/mission/resume",
            "/ground_air/mission/cancel",
            "/ground_air/takeoff",
            "/ground_air/land",
            "/ground_air/emergency_stop",
        ):
            self.assertIn(service, self.text)

    def test_unknown_pose_relocalization_is_supported(self):
        self.assertIn("request.use_initial_guess = j.contains(\"pose\")", self.text)
        self.assertIn("cli_ground_air_relocalize_.call", self.text)
        self.assertIn('j.value("timeout", 60.0)', self.text)
        self.assertIn('r["rmse"] = srv.response.rmse', self.text)

    def test_mapping_commands_return_real_recorder_results(self):
        self.assertIn("cli_ground_air_mapping_start_.call", self.text)
        self.assertIn("cli_ground_air_mapping_save_.call", self.text)
        self.assertIn("srv.request.map_id", self.text)
        self.assertIn('r["map_directory"] = srv.response.map_directory', self.text)
        self.assertNotIn("saveLatestMapFromOccupancyGrid();", self.text)

    def test_mission_is_submitted_as_one_ordered_goal_array(self):
        self.assertIn("request.goals.push_back", self.text)
        self.assertIn("cli_ground_air_mission_submit_.call", self.text)
        self.assertIn("cli_ground_air_mission_start_.call", self.text)

    def test_takeoff_height_is_not_accepted_from_platform(self):
        self.assertIn('r["altitude"] = cfg_.default_takeoff_altitude;', self.text)
        self.assertNotIn('j.value("altitude", cfg_.default_takeoff_altitude)', self.text)

    def test_platform_has_separate_latched_estop_reset_command(self):
        self.assertIn('handlers_["emergency_reset_down"]', self.text)
        self.assertIn("handleEmergencyStop(j, false)", self.text)
        self.assertIn("srv.request.active = active", self.text)
        self.assertIn('active ? "emergency_stop_up" : "emergency_reset_up"', self.text)


if __name__ == "__main__":
    unittest.main()
