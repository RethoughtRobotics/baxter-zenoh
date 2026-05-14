cmake_minimum_required(VERSION 3.5)
project(motor_controller)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "srv/ListControllers.srv"
  "srv/ListControllerTypes.srv"
  "srv/LoadController.srv"
  "srv/ReloadControllerLibraries.srv"
  "srv/SwitchControllers.srv"
  "srv/UnloadController.srv"
)

install(
  FILES mapping_rules.yaml
  DESTINATION share/${PROJECT_NAME})

ament_package()
