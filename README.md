# Baxter Bridge

![ROS2 Jazzy](https://img.shields.io/badge/ROS2_Jazzy-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Kilted](https://img.shields.io/badge/ROS2_Kilted-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Lyrical](https://img.shields.io/badge/ROS2_Lyrical-compatible-brightgreen?logo=ros&logoColor=white)

![Baxter Bridge overview diagram](overview.png)

This container bridges Baxter's ROS 1 (`rosmaster` on the robot) to ROS 2 on your laptop using [`ros1_bridge`](https://github.com/RethoughtRobotics/ros1_bridge) over Zenoh. For a deep dive into how it works, see [Architecture](ARCHITECTURE.md).

---

```bash
git clone git@github.com:RethoughtRobotics/baxter-zenoh.git
cd ~/baxter-zenoh
```

---

## 1. One-time setup

Connect your laptop to the robot via Ethernet, then run:

```bash
bash setup.sh
source ~/.bashrc
```

This installs the Ethernet profile, Zenoh middleware, and adds `baxter_start` / `baxter_env` aliases to your shell.

Then build the Docker image and ROS 2 message definitions:

```bash
docker build -t baxter-zenoh:latest .       # ~15 min
cd ~/baxter-zenoh/ros2_msgs && colcon build
```

---

## 2. Each session

Open two terminals:

| Terminal 1 — Bridge | Terminal 2 — Your ROS 2 work |
|---|---|
| `baxter_start` | `baxter_env` |

**Terminal 1** runs the bridge and stays open. **Terminal 2** (and any others you open) run `baxter_env` once to arm the shell, then you're live.

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

## 3. Controlling the robot

For robot control, enabling/disabling, and higher-level ROS 2 APIs see:

<a href="https://github.com/RethoughtRobotics/BaxterSDK">
  <img src="https://gh-card.dev/repos/RethoughtRobotics/BaxterSDK.svg?fullname=" width="100%" />
</a>

**Verify the bridge is working**
```bash
ros2 topic echo /robot/joint_states
```
**Enable the robot**
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

The Rethink Ethernet profile has not been installed on this machine. Run the one-time setup:

```bash
bash setup.sh
```

</details>
