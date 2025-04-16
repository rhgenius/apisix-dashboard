#!/bin/bash
set -e

echo "Stopping and disabling services..."
sudo systemctl stop apisix-dashboard.service || true
sudo systemctl disable apisix-dashboard.service || true
sudo systemctl stop apisix.service || true
sudo systemctl disable apisix.service || true

# Remove systemd service files
echo "Removing systemd service files..."
sudo rm -f /etc/systemd/system/apisix-dashboard.service
sudo rm -f /etc/systemd/system/apisix.service
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

# Remove logs
echo "Removing APISIX logs..."
sudo rm -rf /usr/local/apisix/logs

# Remove APISIX repository key
echo "Removing APISIX repository key..."
sudo apt-key del $(sudo apt-key list | grep -B 1 'APISIX' | head -n 1 | awk '{print $2}') || true

# Remove downloaded dashboard files
echo "Cleaning up downloaded dashboard files..."
rm -rf executable.tar.gz output

# Final message
echo "Uninstallation completed successfully!"
