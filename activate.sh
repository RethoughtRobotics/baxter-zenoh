#!/usr/bin/env bash
# Source this file to prepare a terminal for Baxter ROS 2 work.
# Usage: source activate.sh   (or via the baxter_env alias)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source /opt/ros/"${ROS_DISTRO:-kilted}"/setup.bash

if [[ -f "$REPO_DIR/ros2_msgs/install/setup.bash" ]]; then
    source "$REPO_DIR/ros2_msgs/install/setup.bash"
else
    echo "Note: Baxter message types unavailable. Run: cd $REPO_DIR/ros2_msgs && colcon build"
fi

unset ROS_DOMAIN_ID
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

echo ""
echo "  Baxter ROS 2 environment ready"
echo "  --------------------------------"
echo "  ROS:  ${ROS_DISTRO}"
echo "  RMW:  ${RMW_IMPLEMENTATION}"
if [[ -f "$REPO_DIR/ros2_msgs/install/setup.bash" ]]; then
    echo "  Msgs: baxter_core_msgs, baxter_maintenance_msgs, arm_navigation_msgs"
fi
if docker ps --filter ancestor=ghcr.io/rethoughtrobotics/baxter-zenoh:latest --format "{{.ID}}" 2>/dev/null | grep -q .; then
    echo "  Bridge: running"
else
    echo "  Bridge: not running — open a new terminal and run baxter_start"
fi
echo ""
