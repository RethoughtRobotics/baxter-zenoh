cmake_minimum_required(VERSION 2.8.3)
project(motor_control_plugins_msgs)

find_package(catkin REQUIRED COMPONENTS
  message_generation
  geometry_msgs
  sensor_msgs
  std_msgs
)

add_service_files(DIRECTORY srv FILES
  DataRecorder.srv
  DynamicPublish.srv
  GenericReadDebugVar.srv
  GenericWriteCyclic.srv
  GenericWriteDebugVar.srv
  GetPositionFK.srv
  GetPositionIK.srv
  InjectSonarData.srv
  SetAssemblyEnable.srv
  SetControllerGains.srv
  SetEnable.srv
  SetFunction.srv
  SetGravityCompensationEnable.srv
  SetGravityCompensationTare.srv
  SetJointState.srv
  SetLimbEnable.srv
  SetReference.srv
  SetSupervisorEnable.srv
  SetSupervisorReset.srv
  SetSupervisorStop.srv
  TareLoadCell.srv
)

generate_messages(DEPENDENCIES geometry_msgs sensor_msgs std_msgs)

catkin_package(CATKIN_DEPENDS message_runtime geometry_msgs sensor_msgs std_msgs)
