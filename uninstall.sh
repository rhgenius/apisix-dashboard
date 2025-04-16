#!/bin/bash
set -e

echo "Stopping and disabling services..."
sudo systemctl stop apisix-dashboard.service || true
sudo systemctl disable apisix-dashboard.service || true
sudo systemctl stop apisix.service || true
sudo systemctl disable apisix.service || true
sudo systemctl stop etcd.service || true
sudo systemctl disable etcd.service || true

# Remove systemd service files
echo "Removing systemd service files..."
sudo rm -f /etc/systemd/system/apisix-dashboard.service
sudo rm -f /etc/systemd/system/apisix.service
sudo rm -f /etc/systemd/system/etcd.service
sudo systemctl daemon-reload

# Remove APISIX Dashboard files
echo "Removing APISIX Dashboard files..."
sudo rm -rf /opt/apisix-dashboard

# Remove APISIX files and config
echo "Removing APISIX files and config..."
sudo rm -rf /usr/local/apisix
sudo rm -f /etc/apt/sources.list.d/apisix.list
sudo rm -rf /usr/bin/apisix

# Remove APISIX installed by apt
echo "Removing APISIX package..."
sudo apt-get remove --purge -y apisix || true
sudo apt-get autoremove -y

# Remove etcd files and config
echo "Removing etcd files and config..."
sudo rm -rf /opt/etcd
sudo rm -rf /var/log/etcd
sudo rm -rf etcd-v3.5.0-linux-amd64.tar.gz etcd-v3.5.0-linux-amd64

# Remove logs
echo "Removing APISIX and etcd logs..."
sudo rm -rf /usr/local/apisix/logs
sudo rm -f /var/log/etcd/etcd.log /var/log/etcd/etcd_error.log

# Remove APISIX repository key
echo "Removing APISIX repository key..."
sudo apt-key del $(sudo apt-key list | grep -B 1 'APISIX' | head -n 1 | awk '{print $2}') || true

# Remove downloaded dashboard files
echo "Cleaning up downloaded dashboard files..."
rm -rf executable.tar.gz output

# Final message
echo "Uninstallation completed successfully!"
