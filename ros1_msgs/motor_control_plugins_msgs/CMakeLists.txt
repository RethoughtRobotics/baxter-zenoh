cmake_minimum_required(VERSION 2.8.3)
project(motor_control_plugins_msgs)

find_package(catkin REQUIRED COMPONENTS message_generation)

add_service_files(DIRECTORY srv FILES
  SetGravityCompensationEnable.srv
  SetGravityCompensationTare.srv
)

generate_messages()

catkin_package(CATKIN_DEPENDS message_runtime)
