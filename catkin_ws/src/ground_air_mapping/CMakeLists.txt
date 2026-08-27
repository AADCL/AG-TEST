cmake_minimum_required(VERSION 3.0.2)
project(ground_air_mapping)

add_compile_options(-std=c++14 -Wall -Wextra)

find_package(catkin REQUIRED COMPONENTS
  ground_air_msgs
  nav_msgs
  roscpp
  sensor_msgs
  std_srvs
)

catkin_package(
  INCLUDE_DIRS include
  CATKIN_DEPENDS ground_air_msgs nav_msgs roscpp sensor_msgs std_srvs
)

include_directories(include ${catkin_INCLUDE_DIRS})

add_executable(map_recorder_node src/map_recorder_node.cpp)
add_dependencies(map_recorder_node ${catkin_EXPORTED_TARGETS})
target_link_libraries(map_recorder_node ${catkin_LIBRARIES})

install(TARGETS map_recorder_node
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)
install(DIRECTORY include/${PROJECT_NAME}/
  DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
)
install(DIRECTORY launch/
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/launch
)

if(CATKIN_ENABLE_TESTING)
  catkin_add_nosetests(tests/test_mapping_package_contract.py)
  add_executable(test_voxel_accumulator tests/test_voxel_accumulator.cpp)
  target_include_directories(test_voxel_accumulator PRIVATE include)
  add_test(NAME ground_air_mapping_voxel_accumulator COMMAND test_voxel_accumulator)
endif()
