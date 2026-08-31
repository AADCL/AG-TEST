#!/usr/bin/env python3
import pathlib
import unittest
import xml.etree.ElementTree as ET

import yaml


WORKSPACE_SRC = pathlib.Path(__file__).resolve().parents[2]
BRINGUP = WORKSPACE_SRC / "car_bringup"
VIDEO_PACKAGE = WORKSPACE_SRC / "EPGeneral_video_srt"
DEVICE_PACKAGE = WORKSPACE_SRC / "EPGeneral_device_config"


class A8CcsVideoProfileContractTests(unittest.TestCase):
    def test_a8_profile_matches_ccs_listener_contract(self):
        profile_path = BRINGUP / "config" / "a8_video.yaml"
        profile = yaml.safe_load(profile_path.read_text(encoding="utf-8"))
        self.assertEqual(profile["image_topic"], "/a8_cam/image_raw")
        self.assertEqual(profile["image_message_type"], "sensor_msgs/Image")
        self.assertEqual(profile["output_width"], 640)
        self.assertEqual(profile["output_height"], 480)
        self.assertEqual(profile["framerate"], 30)
        self.assertEqual(profile["srt_bind_address"], "0.0.0.0")
        self.assertEqual(profile["srt_port"], 9000)
        self.assertEqual(profile["srt_latency_ms"], 120)
        self.assertEqual(profile["bitrate_kbps"], 2000)
        self.assertEqual(profile["frame_timeout_seconds"], 5.0)

    def test_device_identity_matches_ground_air_robot(self):
        device_path = DEVICE_PACKAGE / "config" / "device.yaml"
        device = yaml.safe_load(device_path.read_text(encoding="utf-8"))
        self.assertEqual(device["schema_version"], 1)
        self.assertEqual(device["device"]["id"], "AGV_001")
        self.assertEqual(device["device"]["ip"], "192.168.50.130")

    def test_official_srt_node_uses_required_encoding_and_listener_pipeline(self):
        package = (VIDEO_PACKAGE / "package.xml").read_text(encoding="utf-8")
        source = (VIDEO_PACKAGE / "src" / "epgeneral_video_srt_node.cpp").read_text(
            encoding="utf-8"
        )
        self.assertIn("<name>epgeneral_video_srt</name>", package)
        self.assertIn("<version>0.1.0</version>", package)
        for marker in ("mode=listener", "x264enc", "h264parse", "mpegtsmux", "srtsink"):
            self.assertIn(marker, source)


class BaseSystemVideoLaunchContractTests(unittest.TestCase):
    def test_base_system_exposes_safe_video_defaults_and_conditional_includes(self):
        root = ET.parse(BRINGUP / "launch" / "base_system.launch").getroot()
        arguments = {element.attrib["name"]: element.attrib.get("default") for element in root.findall("arg")}
        self.assertEqual(arguments["start_a8_camera"], "true")
        self.assertEqual(arguments["start_video_srt"], "true")
        self.assertEqual(arguments["a8_camera_ip"], "192.168.144.25")
        self.assertEqual(arguments["a8_image_topic"], "/a8_cam/image_raw")
        self.assertEqual(arguments["srt_port"], "9000")

        includes = root.findall("include")
        camera = next(item for item in includes if "a8_mini_camera" in item.attrib["file"])
        video = next(item for item in includes if "epgeneral_video_srt" in item.attrib["file"])
        self.assertEqual(camera.attrib.get("if"), "$(arg start_a8_camera)")
        self.assertEqual(video.attrib.get("if"), "$(arg start_video_srt)")
        self.assertNotEqual(camera.attrib.get("required"), "true")
        self.assertNotEqual(video.attrib.get("required"), "true")

        camera_args = {item.attrib["name"]: item.attrib["value"] for item in camera.findall("arg")}
        self.assertEqual(camera_args["camera_ip"], "$(arg a8_camera_ip)")
        self.assertEqual(camera_args["image_topic"], "$(arg a8_image_topic)")

        video_args = {item.attrib["name"]: item.attrib["value"] for item in video.findall("arg")}
        self.assertEqual(video_args["image_topic"], "$(arg a8_image_topic)")
        self.assertEqual(video_args["srt_port"], "$(arg srt_port)")
        self.assertIn("epgeneral_device_config", video_args["device_config_file"])
        self.assertIn("car_bringup", video_args["video_config_file"])

    def test_srt_launch_allows_profile_topic_and_port_overrides(self):
        launch = ET.parse(VIDEO_PACKAGE / "launch" / "epgeneral_video_srt.launch").getroot()
        arguments = {element.attrib["name"]: element.attrib.get("default") for element in launch.findall("arg")}
        self.assertEqual(arguments["image_topic"], "/camera/image_raw")
        self.assertEqual(arguments["srt_port"], "9000")
        node = launch.find("node")
        parameters = {element.attrib["name"]: element.attrib["value"] for element in node.findall("param")}
        self.assertEqual(parameters["image_topic"], "$(arg image_topic)")
        self.assertEqual(parameters["srt_port"], "$(arg srt_port)")


if __name__ == "__main__":
    unittest.main()
