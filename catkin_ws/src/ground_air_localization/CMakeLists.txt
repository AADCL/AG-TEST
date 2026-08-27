cmake_minimum_required(VERSION 3.0.2)
project(ground_air_localization)

add_compile_options(-std=c++14 -O3)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  ground_air_msgs
  nav_msgs
  roscpp
  rospy
  sensor_msgs
  std_msgs
  tf2
  tf2_ros
)
find_package(Open3D 0.14.1 REQUIRED)

catkin_python_setup()

catkin_package(CATKIN_DEPENDS geometry_msgs ground_air_msgs nav_msgs roscpp rospy sensor_msgs std_msgs tf2 tf2_ros)

include_directories(${catkin_INCLUDE_DIRS} ${Open3D_INCLUDE_DIRS})

add_executable(global_relocalizer_node src/global_relocalizer_node.cpp)
add_dependencies(global_relocalizer_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(global_relocalizer_node Open3D::Open3D ${catkin_LIBRARIES})

catkin_install_python(PROGRAMS
  scripts/map_manager_node.py
  scripts/world_tf_owner_node.py
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(tests)
endif()

install(TARGETS global_relocalizer_node
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch config
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
  OPTIONAL
)
