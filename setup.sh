#!/usr/bin/env bash
# One-time setup for Baxter over Ethernet.
# Run once: bash setup.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Install the Ethernet connection profile
echo "[1/4] Installing Rethink Ethernet profile..."
sudo cp "$REPO_DIR/Rethink.nmconnection" /etc/NetworkManager/system-connections/Rethink
sudo chown root:root /etc/NetworkManager/system-connections/Rethink
sudo chmod 600 /etc/NetworkManager/system-connections/Rethink
sudo systemctl restart NetworkManager
echo "      Ethernet profile installed."

# Add robot hostname
echo "[2/4] Adding baxter.local to /etc/hosts..."
if grep -qF "baxter.local" /etc/hosts; then
    echo "      Already present — skipping."
else
    echo "10.42.0.2 baxter.local" | sudo tee -a /etc/hosts > /dev/null
    echo "      Done."
fi

# Install Zenoh ROS 2 middleware
echo "[3/4] Installing Zenoh ROS 2 middleware (ros-${ROS_DISTRO:?ROS_DISTRO is not set — source your ROS 2 setup first}-rmw-zenoh-cpp)..."
sudo apt-get install -y ros-"$ROS_DISTRO"-rmw-zenoh-cpp
echo "      Zenoh installed."

# Append env vars and aliases to ~/.bashrc
echo "[4/4] Configuring ~/.bashrc..."
if ! grep -qF "# Baxter Bridge" ~/.bashrc; then
    cat >> ~/.bashrc <<EOF

# Baxter Bridge
alias baxter_start='bash $REPO_DIR/connect.sh'
alias baxter_env='source $REPO_DIR/activate.sh'
EOF
    echo "      Added baxter_start and baxter_env aliases."
else
    echo "      Already configured — skipping."
fi

echo ""
echo "Setup complete. Run: source ~/.bashrc"
