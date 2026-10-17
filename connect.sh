#!/usr/bin/env bash
# Connects to Baxter and runs the bridge.
# Usage: bash connect.sh

set -e

IMAGE=ghcr.io/rethoughtrobotics/baxter-zenoh:latest
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
    echo "ERROR: Cannot reach 10.42.0.2 — is the robot on and the cable plugged in?" >&2
    exit 1
fi
echo "Robot is reachable."

echo "Starting bridge..."
# This repo's run_bridge.sh (startup and camera settings) replaces the image's, so editing it
# needs no image rebuild.
docker run --rm --network=host -v "$SCRIPT_DIR/run_bridge.sh:/run_bridge.sh:ro" "$IMAGE"
