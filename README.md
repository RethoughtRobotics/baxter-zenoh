# Baxter Bridge

![ROS2 Jazzy](https://img.shields.io/badge/ROS2_Jazzy-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Kilted](https://img.shields.io/badge/ROS2_Kilted-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Lyrical](https://img.shields.io/badge/ROS2_Lyrical-compatible-brightgreen?logo=ros&logoColor=white)

![alt text](overview.png)

This container bridges Baxter's ROS 1 (`rosmaster` on the robot) to ROS 2 on your laptop using `ros1_bridge` over Zenoh.

---

## 1. One-time setup

<details>
<summary><b>Network configuration (run once per machine)</b></summary>

Connect your laptop to the robot via Ethernet, then run:

```bash
bash network_setup.sh
```

This installs the `Rethink` NetworkManager profile and adds `baxter.local` to `/etc/hosts`.

Then add the following to your `~/.bashrc` so every terminal is configured for the robot:

```bash
export ROS_MASTER_URI=http://10.42.0.2:11311
export ROS_IP=10.42.0.1
unset ROS_HOSTNAME
```

</details>

Build the bridge Docker image:

```bash
docker build -t baxter_bridge:latest .
```

---

## 2. Each session

**Connect to the robot**
```bash
nmcli connection up Rethink
ping -c1 10.42.0.2        # should succeed before continuing
```

**Run the bridge**
```bash
docker run --rm --network=host baxter_bridge:latest
```

The bridge loads `bridge_topics.yaml` from inside the container and starts forwarding all configured topics and services between ROS 1 and ROS 2.

> **Different network?** The default robot IP is `10.42.0.2` and laptop IP is `10.42.0.1`. Override them without rebuilding:
> ```bash
> docker run --rm --network=host \
>   -e ROS_MASTER_URI=http://<robot-ip>:11311 \
>   -e ROS_IP=<your-ip> \
>   baxter_bridge:latest
> ```

---

## 3. Using the bridge from ROS 2

In a separate terminal on your laptop:

```bash
# Install Zenoh middleware (once)
sudo apt install ros-$ROS_DISTRO-rmw-zenoh-cpp

source /opt/ros/$ROS_DISTRO/setup.bash
unset ROS_DOMAIN_ID
export RMW_IMPLEMENTATION=rmw_zenoh_cpp

# Build Baxter ROS 2 message definitions from this repo (once)
cd ros2_msgs/
colcon build
source install/setup.bash
```

All Baxter message types (`baxter_core_msgs`, `baxter_maintenance_msgs`, `arm_navigation_msgs`) are now available to your ROS 2 nodes. All topics in `bridge_topics.yaml` are live on the ROS 2 side.

---

## 4. Controlling the robot

For robot control, enabling/disabling, and higher-level ROS 2 APIs see:

<a href="https://github.com/Rethink-ROS2/BaxterSDK">
  <img src="https://gh-card.dev/repos/Rethink-ROS2/BaxterSDK.svg?fullname=" width="100%" />
</a>

**Verify the bridge is working**
```bash
ros2 topic echo /robot/joint_states
```

