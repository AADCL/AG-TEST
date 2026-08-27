import ast
import os
import unittest
import xml.etree.ElementTree as ET


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))


class DroneModePackageTest(unittest.TestCase):
    def test_px4_driver_exposes_yaw_rate_velocity_target(self):
        path = os.path.join(ROOT, "scripts", "px4_drone.py")
        with open(path, encoding="utf-8") as source_file:
            source = source_file.read()
        tree = ast.parse(source)
        methods = {
            node.name: node
            for cls in tree.body
            if isinstance(cls, ast.ClassDef) and cls.name == "PX4Drone"
            for node in cls.body
            if isinstance(node, ast.FunctionDef)
        }

        self.assertIn("set_velocity_target", methods)
        self.assertIn(
            "yaw_rate",
            [arg.arg for arg in methods["set_velocity_target"].args.args],
        )
        create_velocity_source = ast.get_source_segment(
            source, methods["_create_velocity"]
        )
        hover_source = ast.get_source_segment(source, methods["hover"])
        self.assertIn("twist.twist.angular.z", create_velocity_source)
        self.assertIn("self.yaw_rate = 0.0", hover_source)

    def test_drone_node_contract(self):
        path = os.path.join(ROOT, "scripts", "drone_mode_node.py")
        with open(path, encoding="utf-8") as source_file:
            source = source_file.read()
        tree = ast.parse(source)
        drone_class = next(
            node
            for node in tree.body
            if isinstance(node, ast.ClassDef) and node.name == "DroneModeNode"
        )
        methods = {
            node.name: node
            for node in drone_class.body
            if isinstance(node, ast.FunctionDef)
        }
        init_source = ast.get_source_segment(source, methods["__init__"])
        service_names = [
            call.args[0].value
            for call in ast.walk(methods["__init__"])
            if isinstance(call, ast.Call)
            and isinstance(call.func, ast.Attribute)
            and isinstance(call.func.value, ast.Name)
            and call.func.value.id == "rospy"
            and call.func.attr == "Service"
            and call.args
            and isinstance(call.args[0], ast.Constant)
        ]

        self.assertIn("Trigger", source)
        self.assertIn("TriggerResponse", source)
        self.assertIn("~takeoff", service_names)
        self.assertIn("~land", service_names)
        self.assertIn("rospy.Subscriber(", init_source)
        self.assertIn("rospy.Timer(", init_source)
        self.assertIn('switch_mode("drone")', init_source)
        self.assertIn('self._positive_param("takeoff_height", 1.0)', init_source)
        self.assertNotIn(".takeoff(", init_source)
        self.assertIn("_takeoff_service", methods)
        self.assertIn("_land_service", methods)
        self.assertIn("_cmd_vel_callback", methods)
        self.assertIn("_control_timer", methods)

    def test_drone_node_serializes_state_transitions_and_velocity_publish(self):
        path = os.path.join(ROOT, "scripts", "drone_mode_node.py")
        with open(path, encoding="utf-8") as source_file:
            source = source_file.read()
        tree = ast.parse(source)
        drone_class = next(
            node
            for node in tree.body
            if isinstance(node, ast.ClassDef) and node.name == "DroneModeNode"
        )
        methods = {
            node.name: node
            for node in drone_class.body
            if isinstance(node, ast.FunctionDef)
        }

        init_source = ast.get_source_segment(source, methods["__init__"])
        self.assertIn("self._state_lock = threading.Lock()", init_source)
        for method_name in (
            "_takeoff_service",
            "_land_service",
            "_cmd_vel_callback",
            "_control_timer",
        ):
            method_source = ast.get_source_segment(source, methods[method_name])
            self.assertIn("with self._state_lock", method_source)

    def test_bz_navigation_conditionally_starts_drone_mode(self):
        launch_path = os.path.join(ROOT, "launch", "bz_navigation.launch")
        launch_root = ET.parse(launch_path).getroot()
        arguments = {
            element.attrib["name"]: element.attrib.get("default")
            for element in launch_root.findall("arg")
        }
        expected_arguments = {
            "enable_drone_mode": "false",
            "drone_cmd_vel_topic": "/cmd_vel",
            "takeoff_height": "1.0",
            "cmd_vel_timeout": "0.5",
            "max_horizontal_speed": "1.0",
            "max_yaw_rate": "1.0",
            "altitude_kp": "1.0",
            "max_vertical_speed": "0.5",
            "control_rate": "20.0",
            "navigation_cmd_vel_topic": "/navigation/cmd_vel",
        }
        self.assertEqual(arguments, expected_arguments)

        control_includes = [
            include for include in launch_root.findall("include")
            if "ground_air_control" in include.attrib.get("file", "")
        ]
        self.assertEqual(len(control_includes), 1)
        control_include = control_includes[0]
        self.assertEqual(control_include.attrib.get("if"), "$(arg enable_drone_mode)")
        parameters = {
            arg.attrib["name"]: arg.attrib["value"]
            for arg in control_include.findall("arg")
        }
        self.assertEqual(
            parameters,
            {
                "takeoff_height": "$(arg takeoff_height)",
                "cmd_vel_timeout": "$(arg cmd_vel_timeout)",
                "control_rate": "$(arg control_rate)",
            },
        )

    def test_package_declares_drone_runtime_dependencies(self):
        package_path = os.path.join(ROOT, "package.xml")
        package_root = ET.parse(package_path).getroot()
        runtime_dependencies = {
            element.text.strip()
            for tag in ("run_depend", "exec_depend")
            for element in package_root.findall(tag)
            if element.text
        }
        for dependency in (
            "rospy",
            "geometry_msgs",
            "std_srvs",
            "sensor_msgs",
            "mavros_msgs",
            "ground_air_control",
        ):
            self.assertIn(dependency, runtime_dependencies)

    def test_cmake_installs_drone_python_files(self):
        cmake_path = os.path.join(ROOT, "CMakeLists.txt")
        with open(cmake_path, encoding="utf-8") as cmake_file:
            cmake_source = cmake_file.read()
        self.assertIn("catkin_install_python", cmake_source)
        self.assertIn("scripts/drone_mode_node.py", cmake_source)
        self.assertIn("scripts/drone_mode_control.py", cmake_source)
        self.assertIn("scripts/px4_drone.py", cmake_source)


if __name__ == "__main__":
    unittest.main()
