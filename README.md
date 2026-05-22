# Baxter Bridge

![ROS2 Jazzy](https://img.shields.io/badge/ROS2_Jazzy-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Kilted](https://img.shields.io/badge/ROS2_Kilted-compatible-brightgreen?logo=ros&logoColor=white)
![ROS2 Lyrical](https://img.shields.io/badge/ROS2_Lyrical-compatible-brightgreen?logo=ros&logoColor=white)

![Baxter Bridge overview diagram](overview.png)

This container bridges Baxter's ROS 1 (`rosmaster` on the robot) to ROS 2 on your laptop using [`ros1_bridge`](https://github.com/RethoughtRobotics/ros1_bridge) over Zenoh. For a deep dive into how it works, see [Architecture](ARCHITECTURE.md).

---

### Clone the repo

```bash
git clone git@github.com:RethoughtRobotics/baxter-zenoh.git
cd ~/baxter-zenoh
```

---

## 1. One-time setup

Run once on any machine you want to use with Baxter:

```bash
bash setup.sh
source ~/.bashrc
```

This installs the Ethernet profile, Zenoh middleware, and adds `baxter_start` / `baxter_env` aliases to your shell.

Then pull the Docker image and build the ROS 2 message definitions:

```bash
docker pull ghcr.io/rethoughtrobotics/baxter-zenoh:latest
cd ~/baxter-zenoh/ros2_msgs && colcon build
```

---

## 2. Each session

Make sure the robot is on and the Ethernet cable is connected, then open two terminals:

| Terminal 1 — Bridge | Terminal 2 — Your ROS 2 work |
|---|---|
| `baxter_start` | `baxter_env` |

**Terminal 1** runs the bridge and stays open. **Terminal 2** (and any others you open) run `baxter_env` once to arm the shell, then you're live.

---

## 3. Controlling the robot

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

## 4. Next steps

Once the bridge is running, use the Baxter SDK for higher-level control - motion planning, gripper control, joint commands, and building your own ROS 2 applications:

<a href="https://github.com/RethoughtRobotics/BaxterSDK">
  <img src="https://gh-card.dev/repos/RethoughtRobotics/BaxterSDK.svg?fullname=" width="50%" />
</a>

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
