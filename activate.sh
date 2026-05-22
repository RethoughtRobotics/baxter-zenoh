#!/usr/bin/env bash
# Source this file to prepare a terminal for Baxter ROS 2 work.
# Usage: source activate.sh   (or via the baxter_env alias)

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source /opt/ros/"${ROS_DISTRO:-kilted}"/setup.bash
source "$REPO_DIR/ros2_msgs/install/setup.bash"

unset ROS_DOMAIN_ID
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

echo "Baxter ROS 2 environment ready. RMW: $RMW_IMPLEMENTATION"
