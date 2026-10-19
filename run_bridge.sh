#!/usr/bin/env bash
set -e

export ROS_MASTER_URI=${ROS_MASTER_URI:-http://10.42.0.2:11311}
export ROS_IP=${ROS_IP:-10.42.0.1}
unset ROS_HOSTNAME
unset ROS_DOMAIN_ID

source /opt/ros/one/setup.bash
source /ros1_ws/devel/setup.bash
source /opt/ros/kilted/setup.bash
source /ros2_ws/install/setup.bash
source /bridge_ws/install/local_setup.bash

export RMW_IMPLEMENTATION=rmw_zenoh_cpp

# Start zenoh daemon; use trap to ensure it is cleaned up if we exit before executing the bridge
ros2 run rmw_zenoh_cpp rmw_zenohd &
ZENOHD_PID=$!
trap 'kill "$ZENOHD_PID" 2>/dev/null; wait "$ZENOHD_PID" 2>/dev/null' EXIT

# Wait for zenohd to open its router port (7447)
echo "Waiting for zenoh daemon (pid $ZENOHD_PID)..."
until timeout 1 bash -c 'echo >/dev/tcp/localhost/7447' 2>/dev/null; do
    kill -0 "$ZENOHD_PID" 2>/dev/null || { echo "ERROR: zenohd exited unexpectedly" >&2; exit 1; }
    sleep 1
done
echo "Zenoh daemon ready."

# Wait for ROS 1 master
MASTER_HOST="${ROS_MASTER_URI#http://}"
MASTER_HOST="${MASTER_HOST%:*}"
MASTER_PORT="${ROS_MASTER_URI##*:}"
echo "Waiting for ROS master at $ROS_MASTER_URI..."
until timeout 1 bash -c "echo >/dev/tcp/${MASTER_HOST}/${MASTER_PORT}" 2>/dev/null; do
    sleep 2
done
echo "ROS master ready."

rosparam load /bridge_topics.yaml

# Hand camera settings, the default for everything that uses the robot. Baxter opens them on
# auto exposure, which runs dim; exposure 40 is about auto's own shutter time, so gain 8
# brightens them without more motion blur or lag (matched to the third_eye RealSense overhead,
# 2026-10-07). Controls (baxter_core_msgs/CameraControl): 100 exposure 0-100, 101 gain 0-79,
# -1 = auto. Applied in the background once the camera service is up, so the bridge starts at once.
# ROS 1 only: with the Kilted setup above also on PYTHONPATH, rosservice fails to import
# (ROS 2's rosgraph_msgs shadows ROS 1's), so this runs in a clean environment.
# Override with CAMERA_SETTINGS (docker run -e); set it empty to leave the cameras untouched.
DEFAULT_CAMERA_SETTINGS='{width: 640, height: 400, fps: 25, controls: [{id: 100, value: 40}, {id: 101, value: 8}]}'
CAMERA_SETTINGS="${CAMERA_SETTINGS-$DEFAULT_CAMERA_SETTINGS}"
[[ -n "$CAMERA_SETTINGS" ]] && env -i HOME="$HOME" PATH=/usr/bin:/bin ROS_MASTER_URI="$ROS_MASTER_URI" ROS_IP="$ROS_IP" \
    CAMERA_SETTINGS="$CAMERA_SETTINGS" bash -c '
    source /opt/ros/one/setup.bash; source /ros1_ws/devel/setup.bash
    until rosservice list 2>/dev/null | grep -qx /cameras/open; do sleep 2; done
    for camera in left_hand_camera right_hand_camera; do
        rosservice call /cameras/open "{name: $camera, settings: $CAMERA_SETTINGS}" >/dev/null \
            && echo "Opened $camera: $CAMERA_SETTINGS" || echo "WARNING: could not set up $camera" >&2
    done' &

exec ros2 run ros1_bridge parameter_bridge
