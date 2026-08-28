cmake_minimum_required(VERSION 3.0.2)
project(ground_air_mission)

find_package(catkin REQUIRED COMPONENTS
  actionlib
  actionlib_msgs
  geometry_msgs
  ground_air_msgs
  move_base_msgs
  rospy
  std_srvs
)

catkin_package(CATKIN_DEPENDS actionlib actionlib_msgs geometry_msgs ground_air_msgs move_base_msgs rospy std_srvs)

catkin_install_python(PROGRAMS
  scripts/mission_executor_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(FILES scripts/mission_executor_core.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch config
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
  OPTIONAL
)
