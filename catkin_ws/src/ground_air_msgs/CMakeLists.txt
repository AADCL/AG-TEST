cmake_minimum_required(VERSION 3.0.2)
project(ground_air_msgs)

find_package(catkin REQUIRED COMPONENTS
  geometry_msgs
  message_generation
  std_msgs
)

add_message_files(FILES
  MissionStatus.msg
  MappingStatus.msg
  VehicleStatus.msg
)

add_service_files(FILES
  LoadMap.srv
  Relocalize.srv
  SaveMapping.srv
  SetEmergencyStop.srv
  SetVehicleMode.srv
  SubmitMission.srv
  StartMapping.srv
)

generate_messages(DEPENDENCIES geometry_msgs std_msgs)

catkin_package(CATKIN_DEPENDS geometry_msgs message_runtime std_msgs)
