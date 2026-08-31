cmake_minimum_required(VERSION 3.0.2)
project(a8_mini_camera)

find_package(catkin REQUIRED COMPONENTS
  cv_bridge
  rospy
  sensor_msgs
)

catkin_python_setup()
catkin_package()

catkin_install_python(PROGRAMS
  scripts/a8_mini_camera_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(tests/test_a8_mini_camera_core.py)
endif()
