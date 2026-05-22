#!/usr/bin/env bash
# One-time network setup for Baxter over Ethernet.
# Run once: bash network_setup.sh

set -e

# Install the Ethernet connection profile
sudo cp "$(dirname "$0")/Rethink.nmconnection" /etc/NetworkManager/system-connections/Rethink
sudo chown root:root /etc/NetworkManager/system-connections/Rethink
sudo chmod 600 /etc/NetworkManager/system-connections/Rethink
sudo systemctl restart NetworkManager

# Add robot hostnames
grep -qF "baxter.local" /etc/hosts || echo "10.42.0.2 baxter.local" | sudo tee -a /etc/hosts

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"

# Append env vars and aliases to ~/.bashrc (idempotent)
if ! grep -qF "# Baxter Bridge" ~/.bashrc; then
    cat >> ~/.bashrc <<EOF

# Baxter Bridge
export ROS_MASTER_URI=http://10.42.0.2:11311
export ROS_IP=10.42.0.1
unset ROS_HOSTNAME
alias baxter_start='bash $REPO_DIR/connect.sh'
alias baxter_env='source $REPO_DIR/activate.sh'
EOF
    echo "Added baxter_start and baxter_env aliases to ~/.bashrc."
else
    echo "~/.bashrc already configured — skipping."
fi

echo "Done. Run: source ~/.bashrc"
