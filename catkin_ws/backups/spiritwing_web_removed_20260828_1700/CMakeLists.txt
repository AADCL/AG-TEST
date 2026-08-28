cmake_minimum_required(VERSION 3.0.2)
project(spiritwing_web)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wno-unused-parameter -Wno-deprecated-declarations)
endif()

find_package(catkin REQUIRED COMPONENTS
  actionlib_msgs
  roscpp
  roslib
  std_msgs
  sensor_msgs
  nav_msgs
  geometry_msgs
  ground_air_msgs
  mavros_msgs
  tf2
  tf2_geometry_msgs
  std_srvs
)

find_package(OpenSSL REQUIRED)
find_package(yaml-cpp REQUIRED)
find_package(nlohmann_json 3.2.0 QUIET)

find_package(libhv QUIET)
if(NOT libhv_FOUND)
  message(STATUS "[spiritwing_web] libhv CMake config not found, falling back to manual lookup")
  find_path(LIBHV_INCLUDE_DIR
    NAMES hv/WebSocketClient.h
    PATHS /usr/local/include /usr/include
  )
  find_library(LIBHV_LIBRARY
    NAMES hv
    PATHS /usr/local/lib /usr/lib /usr/lib/x86_64-linux-gnu
  )
  if(NOT LIBHV_INCLUDE_DIR OR NOT LIBHV_LIBRARY)
    message(FATAL_ERROR "[spiritwing_web] libhv not found. Please install libhv first.")
  endif()
endif()

catkin_package(
  CATKIN_DEPENDS
    actionlib_msgs
    roscpp
    roslib
    std_msgs
    sensor_msgs
    nav_msgs
    geometry_msgs
    ground_air_msgs
    mavros_msgs
    tf2
    tf2_geometry_msgs
    std_srvs
)

include_directories(
  src
  ${catkin_INCLUDE_DIRS}
)

if(NOT libhv_FOUND AND LIBHV_INCLUDE_DIR)
  include_directories(${LIBHV_INCLUDE_DIR})
endif()

add_executable(spiritwing_web_node src/spiritwing_web_node.cpp)
add_dependencies(spiritwing_web_node ${catkin_EXPORTED_TARGETS})

target_link_libraries(spiritwing_web_node
  ${catkin_LIBRARIES}
  yaml-cpp
  OpenSSL::SSL
  OpenSSL::Crypto
  pthread
)

if(libhv_FOUND)
  target_link_libraries(spiritwing_web_node hv)
else()
  target_link_libraries(spiritwing_web_node ${LIBHV_LIBRARY})
endif()

if(TARGET nlohmann_json::nlohmann_json)
  target_link_libraries(spiritwing_web_node nlohmann_json::nlohmann_json)
endif()

install(TARGETS spiritwing_web_node
  RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(PROGRAMS scripts/spiritwing_camera_push.sh
  DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY launch config scripts
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
  USE_SOURCE_PERMISSIONS
  OPTIONAL
)
