#!/usr/bin/env python3
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class GroundAirMessageContractTests(unittest.TestCase):
    def test_required_message_and_service_files_exist(self):
        package = ROOT / "src" / "ground_air_msgs"
        required = {
            "msg/VehicleStatus.msg",
            "msg/MissionStatus.msg",
            "msg/MappingStatus.msg",
            "srv/SetVehicleMode.srv",
            "srv/SetEmergencyStop.srv",
            "srv/SubmitMission.srv",
            "srv/LoadMap.srv",
            "srv/Relocalize.srv",
            "srv/StartMapping.srv",
            "srv/SaveMapping.srv",
        }
        existing = {
            str(path.relative_to(package)).replace("\\", "/")
            for path in package.rglob("*")
            if path.is_file()
        } if package.exists() else set()
        self.assertTrue(required.issubset(existing), required - existing)

    def test_vehicle_status_has_safety_critical_fields(self):
        source = (ROOT / "src/ground_air_msgs/msg/VehicleStatus.msg").read_text()
        for field in (
            "uint8 mode",
            "bool connected",
            "bool armed",
            "bool localized",
            "bool emergency_stop",
            "float32 altitude",
            "string detail",
        ):
            self.assertIn(field, source)

    def test_mission_contract_carries_ordered_pose_array(self):
        source = (ROOT / "src/ground_air_msgs/srv/SubmitMission.srv").read_text()
        self.assertIn("geometry_msgs/PoseStamped[] goals", source)
        self.assertIn("bool accepted", source)

    def test_localization_contract_supports_unknown_pose(self):
        source = (ROOT / "src/ground_air_msgs/srv/Relocalize.srv").read_text()
        self.assertIn("bool use_initial_guess", source)
        self.assertIn("geometry_msgs/PoseWithCovarianceStamped initial_guess", source)
        self.assertIn("float64 fitness", source)
        self.assertIn("float64 rmse", source)

    def test_mapping_contract_reports_progress_and_saved_bundle(self):
        status = (ROOT / "src/ground_air_msgs/msg/MappingStatus.msg").read_text()
        for field in (
            "uint8 IDLE=0",
            "uint8 RECORDING=1",
            "uint8 SAVING=2",
            "uint8 COMPLETE=3",
            "uint8 ERROR=4",
            "string map_id",
            "uint64 point_count",
            "float64 map_area",
            "string message",
        ):
            self.assertIn(field, status)

        start = (ROOT / "src/ground_air_msgs/srv/StartMapping.srv").read_text()
        self.assertIn("string map_id", start)
        self.assertIn("ground_air_msgs/MappingStatus status", start)

        save = (ROOT / "src/ground_air_msgs/srv/SaveMapping.srv").read_text()
        self.assertIn("string map_directory", save)
        self.assertIn("uint64 point_count", save)
        self.assertIn("float64 map_area", save)
        self.assertIn("ground_air_msgs/MappingStatus status", save)


if __name__ == "__main__":
    unittest.main()
