#!/usr/bin/env bash
# Connects to Baxter and runs the bridge.
# Usage: bash connect.sh

set -e

echo "Bringing up Ethernet connection..."
export ROS_MASTER_URI=http://10.42.0.2:11311
export ROS_IP=10.42.0.1
unset ROS_HOSTNAME
nmcli connection up Rethink

echo "Verifying connectivity..."
if ! ping -c1 -W2 10.42.0.2 &>/dev/null; then
    echo "ERROR: Cannot reach 10.42.0.2 — is the robot on and the cable plugged in?" >&2
    exit 1
fi
echo "Robot is reachable."

echo "Starting bridge..."
docker run --rm --network=host ghcr.io/rethoughtrobotics/baxter-zenoh:latest
