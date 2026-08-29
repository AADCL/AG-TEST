import os
import unittest


PACKAGE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class RosContractTests(unittest.TestCase):
    def _read(self, relative):
        path = os.path.join(PACKAGE, relative)
        self.assertTrue(os.path.isfile(path), "missing {}".format(relative))
        with open(path, "r", encoding="utf-8") as stream:
            return stream.read()

    def test_package_declares_only_required_ros_dependencies(self):
        package = self._read("package.xml")
        for dependency in (
            "epgeneral_task_control",
            "geometry_msgs",
            "ground_air_msgs",
            "rospy",
            "std_srvs",
        ):
            self.assertIn("<depend>{}</depend>".format(dependency), package)
        self.assertNotIn("mavros", package.lower())

    def test_node_uses_fixed_ccs_topics_and_supervised_ground_air_services(self):
        node = self._read("scripts/task_adapter_node.py")
        for token in (
            '"/epgeneral_task_control/execution_command"',
            '"/epgeneral_task_control/execution_feedback"',
            '"/ground_air/mission/submit"',
            '"/ground_air/mission/start"',
            '"/ground_air/mission/cancel"',
            '"/ground_air/mission/status"',
            '"/ground_air/localization/pose"',
        ):
            self.assertIn(token, node)
        for forbidden in (
            "/mavros/",
            "/ground_air/takeoff",
            "/ground_air/land",
            "/ground_air/set_mode",
            "/ground_air/emergency_stop",
        ):
            self.assertNotIn(forbidden, node)

    def test_launch_is_passive_and_configures_bounded_waits(self):
        launch = self._read("launch/task_adapter.launch")
        self.assertIn('type="task_adapter_node.py"', launch)
        self.assertIn('name="mission_root"', launch)
        self.assertIn('name="service_wait_timeout"', launch)
        self.assertIn('name="pose_timeout"', launch)

    def test_cmake_installs_node_and_python_package(self):
        cmake = self._read("CMakeLists.txt")
        self.assertIn("catkin_python_setup()", cmake)
        self.assertIn("scripts/task_adapter_node.py", cmake)
        setup = self._read("setup.py")
        self.assertIn("epaguav_ground_air_task_adapter", setup)


if __name__ == "__main__":
    unittest.main()
