cmake_minimum_required(VERSION 3.5)
project(motor_control_plugins_msgs)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(std_msgs REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "srv/DataRecorder.srv"
  "srv/DynamicPublish.srv"
  "srv/GenericReadDebugVar.srv"
  "srv/GenericWriteCyclic.srv"
  "srv/GenericWriteDebugVar.srv"
  "srv/GetPositionFK.srv"
  "srv/GetPositionIK.srv"
  "srv/InjectSonarData.srv"
  "srv/SetAssemblyEnable.srv"
  "srv/SetControllerGains.srv"
  "srv/SetEnable.srv"
  "srv/SetFunction.srv"
  "srv/SetGravityCompensationEnable.srv"
  "srv/SetGravityCompensationTare.srv"
  "srv/SetJointState.srv"
  "srv/SetLimbEnable.srv"
  "srv/SetReference.srv"
  "srv/SetSupervisorEnable.srv"
  "srv/SetSupervisorReset.srv"
  "srv/SetSupervisorStop.srv"
  "srv/TareLoadCell.srv"
  DEPENDENCIES geometry_msgs sensor_msgs std_msgs
)

install(
  FILES mapping_rules.yaml
  DESTINATION share/${PROJECT_NAME})

ament_package()
