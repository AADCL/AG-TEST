#!/usr/bin/env python3
from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


CATKIN_SRC = Path(__file__).resolve().parents[2]
BZ_LAUNCH = (
    CATKIN_SRC / "teb_local_planner_tutorials" / "launch" / "bz_navigation.launch"
)
CONTROL_LAUNCH = Path(__file__).resolve().parents[1] / "launch" / "control.launch"


class GroundControlLaunchContractTests(unittest.TestCase):
    def test_navigation_and_actuator_rates_are_20_hz(self):
        nav = ET.parse(str(BZ_LAUNCH)).getroot()
        controller = nav.find(".//param[@name='controller_frequency']")
        self.assertIsNotNone(controller)
        self.assertEqual(controller.attrib["value"], "20.0")

        control = CONTROL_LAUNCH.read_text(encoding="utf-8")
        self.assertIn('<arg name="control_rate" default="20.0" />', control)
        self.assertEqual(control.count('<param name="rate" value="$(arg control_rate)" />'), 2)


if __name__ == "__main__":
    unittest.main()
