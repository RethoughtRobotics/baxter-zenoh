#!/usr/bin/env bash
# One-time network setup for Baxter/Sawyer over Ethernet.
# Run once: bash network_setup.sh

set -e

# Install the Ethernet connection profile
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROFILE="$SCRIPT_DIR/Rethink.nmconnection"
if [[ ! -f "$PROFILE" ]]; then
    echo "ERROR: Rethink.nmconnection not found in $SCRIPT_DIR" >&2
    exit 1
fi
sudo cp "$PROFILE" /etc/NetworkManager/system-connections/Rethink
sudo chown root:root /etc/NetworkManager/system-connections/Rethink
sudo chmod 600 /etc/NetworkManager/system-connections/Rethink
sudo systemctl restart NetworkManager

# Add robot hostnames
grep -qF "baxter.local" /etc/hosts || echo "10.42.0.2 baxter.local" | sudo tee -a /etc/hosts

echo "Done. Add the following to your ~/.bashrc:"
echo ""
echo "  export ROS_MASTER_URI=http://10.42.0.2:11311"
echo "  export ROS_IP=10.42.0.1"
echo "  unset ROS_HOSTNAME"
