#!/usr/bin/env bash
# Connects to Baxter and runs the bridge.
# Usage: bash connect.sh

set -e

IMAGE=ghcr.io/rethoughtrobotics/baxter-zenoh:latest

# A second bridge echoes bidirectional topics back and forth and doubles every
# arm command, which starves the robot link.
RUNNING=$(docker ps -q --filter ancestor="$IMAGE")
if [ -n "$RUNNING" ]; then
    echo "ERROR: Baxter bridge already running (container $RUNNING). Stop it first: docker stop $RUNNING" >&2
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
