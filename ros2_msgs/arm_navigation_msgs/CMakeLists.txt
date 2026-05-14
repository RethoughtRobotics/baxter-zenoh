cmake_minimum_required(VERSION 3.5)
project(arm_navigation_msgs)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(builtin_interfaces REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(std_msgs REQUIRED)
find_package(trajectory_msgs REQUIRED)

rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/AllowedCollisionEntry.msg"
  "msg/AllowedCollisionMatrix.msg"
  "msg/AllowedContactSpecification.msg"
  "msg/ArmNavigationErrorCodes.msg"
  "msg/AttachedCollisionObject.msg"
  "msg/CollisionMap.msg"
  "msg/CollisionObject.msg"
  "msg/CollisionObjectOperation.msg"
  "msg/CollisionOperation.msg"
  "msg/Constraints.msg"
  "msg/ContactInformation.msg"
  "msg/DisplayTrajectory.msg"
  "msg/JointConstraint.msg"
  "msg/JointLimits.msg"
  "msg/JointTrajectoryWithLimits.msg"
  "msg/LinkPadding.msg"
  "msg/MotionPlanRequest.msg"
  "msg/MultiDOFJointState.msg"
  "msg/MultiDOFJointTrajectory.msg"
  "msg/MultiDOFJointTrajectoryPoint.msg"
  "msg/OrderedCollisionOperations.msg"
  "msg/OrientationConstraint.msg"
  "msg/OrientedBoundingBox.msg"
  "msg/PlanningScene.msg"
  "msg/PositionConstraint.msg"
  "msg/RobotState.msg"
  "msg/RobotTrajectory.msg"
  "msg/Shape.msg"
  "msg/SimplePoseConstraint.msg"
  "msg/VisibilityConstraint.msg"
  "msg/WorkspaceParameters.msg"
  "srv/GetPlanningScene.srv"
  "srv/GetRobotState.srv"
  "srv/SetPlanningSceneDiff.srv"
  DEPENDENCIES builtin_interfaces geometry_msgs sensor_msgs std_msgs trajectory_msgs
)

install(
  FILES mapping_rules.yaml
  DESTINATION share/${PROJECT_NAME})

ament_package()
