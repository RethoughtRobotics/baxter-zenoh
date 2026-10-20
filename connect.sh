#!/usr/bin/env bash
# Connect to Baxter and run the bridge (the robot's ROS 1 graph on ROS 2).
# Usage: bash connect.sh   (alias: baxter_start)

if [[ " $* " =~ \ (-h|--help)\  ]]; then sed -n '2,/^$/{/^#/s/^# \{0,1\}//p}' "$0"; exit 0; fi
set -e

IMAGE=ghcr.io/rethoughtrobotics/baxter-zenoh:latest

# A second bridge echoes bidirectional topics back and forth and doubles every
# arm command, which starves the robot link.
RUNNING=$(docker ps -q --filter ancestor="$IMAGE")
if [ -n "$RUNNING" ]; then
    echo "ERROR: Baxter bridge already running (container $RUNNING). Stop it first: docker stop $RUNNING" >&2
    exit 1
fi

# The bridge runs the one Zenoh router for the robot. A router another tool started on this port (the
# simulator, a viewer) would take it: the bridge would then route through it and lose the robot when
# that tool's teardown stops it.
if ss -ltnH 'sport = :7447' | grep -q .; then
    echo "ERROR: a Zenoh router already listens on port 7447 (started by the simulator or a viewer)." >&2
    echo "       Stop it first (BaxterSDK: scripts/teardown.sh), then start the bridge." >&2
    exit 1
fi

echo "Bringing up Ethernet connection..."
nmcli connection up Rethink

echo "Verifying connectivity..."
if ! ping -c1 -W2 10.42.0.2 &>/dev/null; then
    echo "ERROR: Cannot reach 10.42.0.2: is the robot on and the cable plugged in?" >&2
    exit 1
fi
echo "Robot is reachable."

echo "Starting bridge..."
docker run --rm --network=host "$IMAGE"
