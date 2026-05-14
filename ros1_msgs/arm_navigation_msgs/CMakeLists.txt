cmake_minimum_required(VERSION 2.8.3)
project(arm_navigation_msgs)

find_package(catkin REQUIRED COMPONENTS
  message_generation
  geometry_msgs
  sensor_msgs
  trajectory_msgs
)

add_message_files(DIRECTORY msg FILES
  AllowedCollisionEntry.msg
  AllowedCollisionMatrix.msg
  AllowedContactSpecification.msg
  ArmNavigationErrorCodes.msg
  AttachedCollisionObject.msg
  CollisionMap.msg
  CollisionObject.msg
  CollisionObjectOperation.msg
  CollisionOperation.msg
  Constraints.msg
  ContactInformation.msg
  DisplayTrajectory.msg
  JointConstraint.msg
  JointLimits.msg
  JointTrajectoryWithLimits.msg
  LinkPadding.msg
  MotionPlanRequest.msg
  MultiDOFJointState.msg
  MultiDOFJointTrajectory.msg
  MultiDOFJointTrajectoryPoint.msg
  OrderedCollisionOperations.msg
  OrientationConstraint.msg
  OrientedBoundingBox.msg
  PlanningScene.msg
  PositionConstraint.msg
  RobotState.msg
  RobotTrajectory.msg
  Shape.msg
  SimplePoseConstraint.msg
  VisibilityConstraint.msg
  WorkspaceParameters.msg
)

add_service_files(DIRECTORY srv FILES
  GetPlanningScene.srv
  GetRobotState.srv
  SetPlanningSceneDiff.srv
)

generate_messages(DEPENDENCIES geometry_msgs sensor_msgs trajectory_msgs)

catkin_package(CATKIN_DEPENDS message_runtime geometry_msgs sensor_msgs trajectory_msgs)
