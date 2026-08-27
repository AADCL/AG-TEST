cmake_minimum_required(VERSION 3.0.2)
project(ground_air_control)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  ground_air_msgs
  mavros_msgs
  rospy
  std_srvs
)

catkin_python_setup()

catkin_package(CATKIN_DEPENDS geometry_msgs ground_air_msgs mavros_msgs rospy std_srvs)

catkin_install_python(PROGRAMS
  scripts/cmd_vel_router_node.py
  scripts/ground_actuator_node.py
  scripts/mode_manager_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(FILES
  scripts/cmd_vel_router_core.py
  scripts/mode_manager_core.py
  scripts/px4_backend.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch config
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
  OPTIONAL
)
