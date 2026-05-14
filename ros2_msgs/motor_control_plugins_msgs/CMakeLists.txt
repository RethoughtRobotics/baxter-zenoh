cmake_minimum_required(VERSION 3.5)
project(motor_control_plugins_msgs)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "srv/SetGravityCompensationEnable.srv"
  "srv/SetGravityCompensationTare.srv"
)

install(
  FILES mapping_rules.yaml
  DESTINATION share/${PROJECT_NAME})

ament_package()
