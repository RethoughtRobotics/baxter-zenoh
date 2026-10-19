FROM osrf/ros:kilted-desktop-full@sha256:c62c1847b106e214fe18b2b8c94222fd3d03897761cce3d16be063be6fc0461d

# ROS-O: Noetic on Ubuntu 24.04 Noble
# Instructions from https://ros.packages.techfak.net
RUN apt-get update && apt-get install -y --no-install-recommends curl gnupg && \
    curl -sSL https://ros.packages.techfak.net/gpg.key \
        -o /etc/apt/keyrings/ros-one-keyring.gpg && \
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/ros-one-keyring.gpg] \
https://ros.packages.techfak.net noble main" \
        > /etc/apt/sources.list.d/ros1.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        ros-one-desktop=1.5.0-1noble.20250602.0114 \
        python3-catkin-tools \
        python3-rosdep && \
    rm -rf /var/lib/apt/lists/*

# ROS 1 baxter messages catkin, built against ROS-O
COPY ros1_msgs/ /ros1_ws/src/

RUN bash -c "\
    source /opt/ros/one/setup.bash && \
    cd /ros1_ws && \
    catkin_make"

# ROS 2 messages, built against Kilted. Baxter's come from BaxterSDK, the one source of its ROS 2
# interfaces: under rmw_zenoh a topic only connects when both ends have the same type hash, so a
# second copy that drifts silently cuts that topic. Pinned like ros1_bridge below.
# arm_navigation_msgs is only ever used by the bridge, so it lives here.
ARG BAXTER_SDK_COMMIT=8d9a77f3bd6f0f144587f89ff823e4e9dafce5f5
RUN git clone https://github.com/RethoughtRobotics/BaxterSDK /tmp/sdk && \
    git -C /tmp/sdk checkout --detach "$BAXTER_SDK_COMMIT" && \
    mkdir -p /ros2_ws/src && \
    mv /tmp/sdk/src/baxter_common/baxter_core_msgs /tmp/sdk/src/baxter_common/baxter_maintenance_msgs \
        /ros2_ws/src/ && \
    rm -rf /tmp/sdk
COPY ros2_msgs/arm_navigation_msgs/ /ros2_ws/src/arm_navigation_msgs/

RUN bash -c "\
    source /opt/ros/kilted/setup.bash && \
    cd /ros2_ws && \
    colcon build --packages-select baxter_core_msgs baxter_maintenance_msgs arm_navigation_msgs"

# ros1_bridge fork with the Kilted build fixes and the executor fix (the ROS 2 node is added to the
# executor once; per-callback spin_node_once() capped the bridge near 115 msgs/s, so two arms
# streaming commands starved one). Pinned to a commit so a rebuild is the image that was tested.
ARG ROS1_BRIDGE_COMMIT=9ca710713c371966916405de5acd5afd282d420b
RUN git clone https://github.com/RethoughtRobotics/ros1_bridge /bridge_ws/src/ros1_bridge && \
    git -C /bridge_ws/src/ros1_bridge checkout --detach "$ROS1_BRIDGE_COMMIT"

RUN bash -c "\
    source /opt/ros/one/setup.bash && \
    source /ros1_ws/devel/setup.bash && \
    source /opt/ros/kilted/setup.bash && \
    source /ros2_ws/install/setup.bash && \
    cd /bridge_ws && \
    colcon build --packages-select ros1_bridge --cmake-force-configure"

# rmw_zenoh_cpp
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-kilted-rmw-zenoh-cpp \
    && rm -rf /var/lib/apt/lists/*

# Entrypoint
COPY bridge_topics.yaml /bridge_topics.yaml
COPY run_bridge.sh /run_bridge.sh
RUN chmod +x /run_bridge.sh
ENTRYPOINT ["/run_bridge.sh"]
