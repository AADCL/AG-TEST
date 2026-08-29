cmake_minimum_required(VERSION 3.0.2)
project(epaguav_ground_air_task_adapter)

find_package(catkin REQUIRED COMPONENTS
  epgeneral_task_control
  geometry_msgs
  ground_air_msgs
  rospy
  std_srvs
)

catkin_python_setup()
catkin_package(CATKIN_DEPENDS
  epgeneral_task_control geometry_msgs ground_air_msgs rospy std_srvs
)

catkin_install_python(PROGRAMS scripts/task_adapter_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION})
install(DIRECTORY launch DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION})

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(tests)
endif()
