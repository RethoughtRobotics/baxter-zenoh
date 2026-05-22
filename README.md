# Baxter Bridge

![ROS2 Jazzy](https://img.shields.io/badge/ROS2_Jazzy-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Kilted](https://img.shields.io/badge/ROS2_Kilted-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Lyrical](https://img.shields.io/badge/ROS2_Lyrical-compatible-brightgreen?logo=ros&logoColor=white)

![Baxter Bridge overview diagram](overview.png)

This container bridges Baxter's ROS 1 (`rosmaster` on the robot) to ROS 2 on your laptop using [`ros1_bridge`](https://github.com/RethoughtRobotics/ros1_bridge) over Zenoh. For a deep dive into how it works, see [Architecture](ARCHITECTURE.md).

---

```bash
git clone git@github.com:RethoughtRobotics/baxter-zenoh.git
```
```bash
cd ~/baxter-zenoh
```

## 1. One-time setup


<summary><b>Network configuration (run once per machine)</b></summary>

Connect your laptop to the robot via Ethernet, then run:

```bash
bash setup.sh
```

This installs the `Rethink` NetworkManager profile, adds `baxter.local` to `/etc/hosts`, installs the Zenoh ROS 2 middleware, and adds `baxter_start` / `baxter_env` aliases to your `~/.bashrc`.

build from source:

```bash
docker build -t baxter-zenoh:latest .
```
**this takes about 15 minutes the first time**

---

## 2. Each session

```bash
baxter_start
```

This connects to the robot via Ethernet, verifies connectivity, and starts the bridge.

<details>
<summary>Different network?</summary>

The default robot IP is `10.42.0.2` and laptop IP is `10.42.0.1`. Override them without rebuilding:

```bash
docker run --rm --network=host \
  -e ROS_MASTER_URI=http://<robot-ip>:11311 \
  -e ROS_IP=<your-ip> \
  baxter-zenoh:latest
```

</details>

---

## 3. Using the bridge from ROS 2

In a separate terminal, build the Baxter ROS 2 message definitions (once):

```bash
cd ~/baxter-zenoh/ros2_msgs && colcon build
```

Then arm any terminal for Baxter work:

```bash
baxter_env
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

Make sure you have run `baxter_env` in your terminal. Without it, `RMW_IMPLEMENTATION` and the Baxter message definitions are not set.

```bash
baxter_env
ros2 topic list
```

If topics are still missing, check that `ROS_DOMAIN_ID` is unset:

```bash
unset ROS_DOMAIN_ID
ros2 topic list
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
<summary><b><code>nmcli connection up Rethink</code> says the connection is unknown</b></summary>

The Rethink Ethernet profile has not been installed on this machine. Run the one-time network setup:

```bash
bash setup.sh
```
</details>