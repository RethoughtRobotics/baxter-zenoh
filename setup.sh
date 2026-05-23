#!/usr/bin/env bash
# One-time setup for Baxter over Ethernet.
# Run once: bash setup.sh

set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Check for nmcli
if ! command -v nmcli &>/dev/null; then
    echo "ERROR: nmcli not found. Install NetworkManager first:" >&2
    echo "  sudo apt-get install network-manager" >&2
    exit 1
fi

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
ZENOH_PKG="ros-${ROS_DISTRO:?ROS_DISTRO is not set - source your ROS 2 setup first}-rmw-zenoh-cpp"
echo "[3/4] Installing Zenoh ROS 2 middleware ($ZENOH_PKG)..."
if dpkg -s "$ZENOH_PKG" &>/dev/null; then
    echo "      Already installed — skipping."
else
    sudo apt-get install -y -q "$ZENOH_PKG" 2>&1 | grep -v "^$" | grep -v "autoremove" | grep -v "automatically installed"
    echo "      Zenoh installed."
fi

# Append aliases to ~/.bashrc
echo "[4/4] Configuring ~/.bashrc..."
if ! grep -qF "# Baxter Bridge" ~/.bashrc; then
    cat >> ~/.bashrc <<EOF

# Baxter Bridge
alias baxter_start='bash $REPO_DIR/connect.sh'
alias bax_msgs='source $REPO_DIR/activate.sh'
EOF
    echo "      Added baxter_start and bax_msgs aliases."
else
    echo "      Already configured — skipping."
fi

echo ""
echo "Setup complete. Run: source ~/.bashrc"
