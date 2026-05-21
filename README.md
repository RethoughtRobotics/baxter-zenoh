# Baxter Bridge

![ROS2 Jazzy](https://img.shields.io/badge/ROS2_Jazzy-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Kilted](https://img.shields.io/badge/ROS2_Kilted-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Lyrical](https://img.shields.io/badge/ROS2_Lyrical-compatible-brightgreen?logo=ros&logoColor=white)

![Baxter Bridge overview diagram](overview.png)

This container bridges Baxter's ROS 1 (`rosmaster` on the robot) to ROS 2 on your laptop using [`ros1_bridge`](https://github.com/RethoughtRobotics/ros1_bridge) over Zenoh.

---

```bash
git clone git@github.com:RethoughtRobotics/baxter-zenoh.git
```
```bash
cd ~/baxter-zenoh
```

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

<!-- Pull the pre-built bridge image:

```bash
docker pull baxter-zenoh:latest
``` -->

build from source:

```bash
docker build -t baxter-zenoh:latest .
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
docker run --rm --network=host baxter-zenoh:latest
```

The bridge loads `bridge_topics.yaml` from inside the container and starts forwarding all configured topics and services between ROS 1 and ROS 2.

> **Different network?** The default robot IP is `10.42.0.2` and laptop IP is `10.42.0.1`. Override them without rebuilding:
> ```bash
> docker run --rm --network=host \
>   -e ROS_MASTER_URI=http://<robot-ip>:11311 \
>   -e ROS_IP=<your-ip> \
>   baxter-zenoh:latest
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
cd ~/baxter-zenoh/ros2_msgs/
colcon build
source install/setup.bash
```

All Baxter message types (`baxter_core_msgs`, `baxter_maintenance_msgs`, `arm_navigation_msgs`) are now available to your ROS 2 nodes. All topics in `bridge_topics.yaml` are live on the ROS 2 side.

---

## 4. Controlling the robot

For robot control, enabling/disabling, and higher-level ROS 2 APIs see:

<a href="https://github.com/RethoughtRobotics/BaxterSDK">
  <img src="https://gh-card.dev/repos/RethoughtRobotics/BaxterSDK.svg?fullname=" width="100%" />
</a>

**Verify the bridge is working**
```bash
ros2 topic echo /robot/joint_states
```
**Enable the robot!**
```bash
ros2 topic pub --once /robot/set_super_enable std_msgs/msg/Bool "{data: true}"
```
**Disable the robot**
```bash
ros2 topic pub --once /robot/set_super_enable std_msgs/msg/Bool "{data: false}"
```
---

## FAQ

<details>
<summary><b>The bridge starts but I see no topics on the ROS 2 side</b></summary>

Make sure `RMW_IMPLEMENTATION=rmw_zenoh_cpp` is set in your terminal. Without it your ROS 2 tools use a different middleware and can't see the bridge.

```bash
export RMW_IMPLEMENTATION=rmw_zenoh_cpp
ros2 topic list
```
If that doesn't work, make sure that your ROS_DOMAIN_ID is unset or the same in both the container and your terminal.
```bash
unset ROS_DOMAIN_ID
ros2 topic list
```
Also make sure you have sourced the Baxter ROS 2 message definitions:
```bash
source ros2_msgs/install/setup.bash
```

</details>

<details>
<summary><b>The bridge exits immediately after starting</b></summary>

The bridge waits for the ROS 1 master before starting. Make sure the robot is on, the Ethernet link is up, and `10.42.0.2` is reachable:

```bash
nmcli connection up Rethink
ping -c1 10.42.0.2
```
</details>
<details>
