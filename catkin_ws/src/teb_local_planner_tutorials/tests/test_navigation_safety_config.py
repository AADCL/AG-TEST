#!/usr/bin/env python3
"""Contract tests for the conservative ground-navigation configuration."""

from pathlib import Path
import unittest

import yaml


ROOT = Path(__file__).resolve().parents[1]


def load_yaml(relative_path):
    with (ROOT / relative_path).open("r", encoding="utf-8") as stream:
        return yaml.safe_load(stream)


class NavigationSafetyConfigTests(unittest.TestCase):
    CONFIGURED_HALF_LENGTH = 0.30
    CONFIGURED_HALF_WIDTH = 0.30

    @staticmethod
    def footprint_extents(points):
        xs = [float(point[0]) for point in points]
        ys = [float(point[1]) for point in points]
        return max(map(abs, xs)), max(map(abs, ys))

    def test_launch_loads_global_planner_configuration(self):
        launch = (ROOT / "launch" / "bz_navigation.launch").read_text(encoding="utf-8")
        self.assertIn("cfg/diff_drive/global_planner_params.yaml", launch)
        self.assertIn('value="global_planner/GlobalPlanner"', launch)

    def test_global_planner_stays_in_known_free_space(self):
        planner = load_yaml("cfg/diff_drive/global_planner_params.yaml")["GlobalPlanner"]
        self.assertIs(planner["allow_unknown"], False)
        self.assertLessEqual(float(planner["default_tolerance"]), 0.25)

    def test_teb_stops_at_tight_goals_with_valid_angular_acceleration(self):
        teb = load_yaml("cfg/diff_drive/teb_local_planner_params.yaml")["TebLocalPlannerROS"]
        self.assertGreater(float(teb["acc_lim_theta"]), 0.0)
        self.assertLessEqual(float(teb["xy_goal_tolerance"]), 0.25)
        self.assertLessEqual(float(teb["yaw_goal_tolerance"]), 0.35)
        self.assertIs(teb["free_goal_vel"], False)

    def test_teb_motion_bounds_exceed_optimizer_penalty_margin(self):
        teb = load_yaml("cfg/diff_drive/teb_local_planner_params.yaml")["TebLocalPlannerROS"]
        margin = float(teb["penalty_epsilon"])
        self.assertGreater(float(teb["acc_lim_x"]), margin)
        self.assertGreater(float(teb["max_vel_x_backwards"]), margin)

    def test_predictive_dynamic_obstacles_wait_for_velocity_estimator(self):
        teb = load_yaml("cfg/diff_drive/teb_local_planner_params.yaml")["TebLocalPlannerROS"]
        self.assertIs(teb["include_dynamic_obstacles"], False)
        self.assertIs(teb["include_costmap_obstacles"], True)

    def test_global_and_local_costmaps_include_low_obstacles(self):
        for relative_path in (
            "cfg/diff_drive/costmap_common_params_global.yaml",
            "cfg/diff_drive/costmap_common_params_local.yaml",
        ):
            config = load_yaml(relative_path)
            sensor = config["obstacle_layer"]["laser_scan_sensor"]
            self.assertGreaterEqual(float(sensor["min_obstacle_height"]), 0.0)
            self.assertLessEqual(float(sensor["min_obstacle_height"]), 0.15)
            self.assertEqual(sensor["topic"], "/cloud_registered_body")

    def test_costmaps_use_configured_square_vehicle_footprint(self):
        for relative_path in (
            "cfg/diff_drive/costmap_common_params_global.yaml",
            "cfg/diff_drive/costmap_common_params_local.yaml",
            "cfg/diff_drive/costmap_common_params.yaml",
        ):
            config = load_yaml(relative_path)
            half_length, half_width = self.footprint_extents(config["footprint"])
            self.assertAlmostEqual(half_length, self.CONFIGURED_HALF_LENGTH)
            self.assertAlmostEqual(half_width, self.CONFIGURED_HALF_WIDTH)

    def test_teb_uses_the_same_complete_vehicle_footprint(self):
        teb = load_yaml("cfg/diff_drive/teb_local_planner_params.yaml")["TebLocalPlannerROS"]
        footprint = teb["footprint_model"]
        self.assertEqual(footprint["type"], "polygon")
        half_length, half_width = self.footprint_extents(footprint["vertices"])
        self.assertAlmostEqual(half_length, self.CONFIGURED_HALF_LENGTH)
        self.assertAlmostEqual(half_width, self.CONFIGURED_HALF_WIDTH)

    def test_local_costmap_rate_does_not_exceed_controller_rate(self):
        local = load_yaml("cfg/diff_drive/local_costmap_params.yaml")["local_costmap"]
        self.assertLessEqual(float(local["update_frequency"]), 5.0)
        self.assertLessEqual(float(local["publish_frequency"]), 5.0)


if __name__ == "__main__":
    unittest.main()
