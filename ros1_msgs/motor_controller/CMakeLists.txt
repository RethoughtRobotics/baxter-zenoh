cmake_minimum_required(VERSION 2.8.3)
project(motor_controller)

find_package(catkin REQUIRED COMPONENTS message_generation)

add_service_files(DIRECTORY srv FILES
  ListControllers.srv
  ListControllerTypes.srv
  LoadController.srv
  ReloadControllerLibraries.srv
  SwitchControllers.srv
  UnloadController.srv
)

generate_messages()

catkin_package(CATKIN_DEPENDS message_runtime)
