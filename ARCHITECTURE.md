# Architecture

## Overview

Baxter runs ROS 1 (Noetic via ROS-O) on its onboard computer. This bridge runs on your laptop in a Docker container, connecting Baxter's ROS 1 topics and services to ROS 2 on your machine.

## Components

### Base Image
Built on `osrf/ros:kilted-desktop-full` (pinned by SHA for reproducibility). ROS 1 (Noetic) is installed on top via the [ROS-O](https://ros.packages.techfak.net) project, which backports Noetic to Ubuntu 24.04 Noble.

### ROS 1 Messages (`ros1_msgs/`)
Catkin packages containing the original Baxter message and service definitions, built against ROS-O. These are the same message types the robot publishes.

### ROS 2 Messages (`ros2_msgs/`)
Colcon packages containing ROS 2 ports of the Baxter messages, with `mapping_rules.yaml` files that tell `ros1_bridge` how to map between ROS 1 and ROS 2 types. Also built on the host so your ROS 2 nodes can use Baxter message types.

### ros1_bridge
A [custom fork](https://github.com/RethoughtRobotics/ros1_bridge) of the official `ros1_bridge`, built from source against both ROS-O and Kilted. Uses `parameter_bridge` mode, which bridges only the topics and services explicitly listed in `bridge_topics.yaml`.

### Zenoh (`rmw_zenoh_cpp`)
Replaces the default DDS middleware. Zenoh is used because it performs significantly better than DDS particularly for high-frequency topics like joint states and camera images.

`rmw_zenoh_cpp` is configured in **router mode**: all ROS 2 nodes connect to a single local `rmw_zenohd` router process rather than discovering each other peer-to-peer. This is critical for this bridge — when `parameter_bridge` starts, it registers all 272 bridged topics with zenohd simultaneously. The router model means that registration is instant and atomic.

### `bridge_topics.yaml`
This lists every topic (with ROS 2 message type) and every service (with ROS 1 service type) to be forwarded between ROS 1 and ROS 2. Loaded onto the ROS 1 parameter server at startup via `rosparam load`.

### `run_bridge.sh`
The container entrypoint. In order:
1. Sets `ROS_MASTER_URI` and `ROS_IP` (overridable via environment variables)
2. Sources all ROS workspaces in the correct order
3. Starts `rmw_zenohd` and waits for it to be ready on port 7447
4. Waits for the ROS 1 master to be reachable
5. Loads `bridge_topics.yaml` onto the parameter server
6. Launches `parameter_bridge`

## Message Mapping

`ros1_bridge` maps between ROS 1 and ROS 2 message types using `mapping_rules.yaml` files in each ROS 2 message package. For example:

```yaml
# ros2_msgs/baxter_core_msgs/mapping_rules.yaml
- ros1_package_name: baxter_core_msgs
  ros1_message_name: JointCommand
  ros2_package_name: baxter_core_msgs
  ros2_message_name: JointCommand
```

Without these rules, `ros1_bridge` cannot bridge custom message types - only standard ROS messages.

## Data Flow

```
Baxter publishes /robot/joint_states (ROS 1)
    → ros1_bridge reads it via ROS 1 subscriber
    → ros1_bridge republishes it as ROS 2 topic
    → Your node subscribes via rmw_zenoh_cpp
```

```
Your node publishes /robot/limb/left/joint_command (ROS 2)
    → ros1_bridge reads it via ROS 2 subscriber
    → ros1_bridge republishes it as ROS 1 topic
    → Baxter's controller receives it
```

Services work the same way but are unidirectional — ROS 2 clients call ROS 1 servers (e.g. the IK solver).
