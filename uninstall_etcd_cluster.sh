#!/bin/bash
# uninstall_etcd_cluster.sh
# Stops etcd, removes all etcd files, systemd service, binaries, data dir, and user.

set -e

SERVICE_FILE="/etc/systemd/system/etcd.service"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/var/lib/etcd"
USER="etcd"

# 1. Stop and disable etcd service if it exists
if systemctl list-unit-files | grep -q '^etcd.service'; then
  sudo systemctl stop etcd || true
  sudo systemctl disable etcd || true
  sudo systemctl daemon-reload
fi

# 2. Remove systemd service file
if [ -f "$SERVICE_FILE" ]; then
  sudo rm -f "$SERVICE_FILE"
  sudo systemctl daemon-reload
fi

# 3. Remove etcd binaries
sudo rm -f "$INSTALL_DIR/etcd" "$INSTALL_DIR/etcdctl"

# 4. Remove data directory
sudo rm -rf "$DATA_DIR"

# 5. Remove etcd user if exists
if id "$USER" >/dev/null 2>&1; then
  sudo userdel "$USER"
fi

echo "etcd cluster and all related files have been uninstalled."
