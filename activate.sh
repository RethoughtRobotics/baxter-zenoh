#!/usr/bin/env bash
# Source this file to prepare a terminal for Baxter ROS 2 work.
# Usage: source activate.sh   (or via the bax_msgs alias)

source /opt/ros/"${ROS_DISTRO:-kilted}"/setup.bash

# Baxter's ROS 2 message types come from the BaxterSDK workspace (see README).
BAXTER_SDK="${BAXTER_SDK:-$HOME/BaxterSDK}"
if [[ -f "$BAXTER_SDK/install/setup.bash" ]]; then
    source "$BAXTER_SDK/install/setup.bash"
else
    echo "Note: Baxter message types unavailable. Build BaxterSDK (see README) or set BAXTER_SDK."
fi

unset ROS_DOMAIN_ID
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

echo ""
echo "  Baxter ROS 2 environment ready"
echo "  --------------------------------"
echo "  ROS:  ${ROS_DISTRO}"
echo "  RMW:  ${RMW_IMPLEMENTATION}"
if [[ -f "$BAXTER_SDK/install/setup.bash" ]]; then
    echo "  Msgs: $BAXTER_SDK"
fi
if docker ps --filter ancestor=ghcr.io/rethoughtrobotics/baxter-zenoh:latest --format "{{.ID}}" 2>/dev/null | grep -q .; then
    echo "  Bridge: running"
else
    echo "  Bridge: not running — open a new terminal and run baxter_start"
fi
echo ""
