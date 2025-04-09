#!/bin/bash
set -e

# Install etcd
ETCD_VER=v3.5.0
echo "Downloading etcd ${ETCD_VER}"
wget "https://github.com/etcd-io/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz"
tar -xvf "etcd-${ETCD_VER}-linux-amd64.tar.gz"
sudo mkdir -p /opt/etcd
sudo mv etcd-${ETCD_VER}-linux-amd64/etcd* /opt/etcd/
sudo mkdir -p /var/log/etcd

# Create etcd systemd service
echo "Creating etcd systemd service"
sudo tee /etc/systemd/system/etcd.service > /dev/null <<EOF
[Unit]
Description=etcd service
After=network.target

[Service]
Type=simple
ExecStart=/opt/etcd/etcd --config-file /opt/etcd/etcd.conf
Restart=always
RestartSec=5
LimitNOFILE=65536
StandardOutput=append:/var/log/etcd/etcd.log
StandardError=append:/var/log/etcd/etcd_error.log

[Install]
WantedBy=multi-user.target
EOF

# Create etcd configuration
echo "Creating etcd configuration"
sudo tee /opt/etcd/etcd.conf > /dev/null <<EOF
listen-client-urls: http://localhost:2379
listen-peer-urls: http://localhost:2380
EOF

# Start and enable etcd service
echo "Starting etcd service"
sudo systemctl daemon-reload
sudo systemctl enable etcd.service
sudo systemctl start etcd.service
echo "etcd service status:"
sudo systemctl status etcd.service --no-pager

# Install APISIX
echo "Installing APISIX dependencies"
sudo apt-get update
sudo apt-get install -y gnupg

echo "Adding APISIX repository"
wget -qO - http://repos.apiseven.com/pubkey.gpg | sudo apt-key add -
echo "deb http://repos.apiseven.com/packages/debian bullseye main" | sudo tee /etc/apt/sources.list.d/apisix.list

echo "Installing APISIX"
sudo apt-get update
sudo apt-get install -y apisix=3.8.0-0

# Create APISIX systemd service
echo "Creating APISIX systemd service"
sudo tee /etc/systemd/system/apisix.service > /dev/null <<EOF
[Unit]
Description=apisix
After=network-online.target
Wants=network-online.target

[Service]
Type=forking
Restart=on-failure
WorkingDirectory=/usr/local/apisix
ExecStartPre=/bin/rm -f /usr/local/apisix/logs/worker_events.sock
ExecStart=/usr/bin/apisix start -c /usr/local/apisix/conf/config.yaml
ExecStop=/usr/bin/apisix stop
ExecReload=/usr/bin/apisix reload
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

# Configure APISIX
echo "Configuring APISIX"
sudo tee /usr/local/apisix/conf/config.yaml > /dev/null <<EOF
apisix:
  node_listen:
    - port: 443
      enable: true
  ssl:
    ssl_protocol: TLSv1.2 TLSv1.3
    ssl_ciphers: 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305'
    ssl_prefer_server_ciphers: on
    ssl_session_timeout: 1d
    ssl_session_cache: shared:SSL:10m
    ssl_stapling: on
    ssl_stapling_verify: on
deployment:
  role: traditional
  role_traditional:
    config_provider: etcd
  admin:
    admin_key:
      - name: admin
        key: edd1c9f034335f136f87ad84b625c8f1
        role: admin
  etcd:
    host:
      - "http://localhost:2379"
EOF

# Start and enable APISIX service
echo "Starting APISIX service"
sudo systemctl daemon-reload
sudo systemctl enable apisix.service
sudo systemctl start apisix.service
echo "APISIX service status:"
sudo systemctl status apisix.service --no-pager

# Install APISIX Dashboard
rm -rf /opt/apisix-dashboard
wget https://github.com/rhgenius/apisix-dashboard/releases/download/v3.0.1/executable.tar.gz
tar -xvf executable.tar.gz
mkdir -p /opt/apisix-dashboard
cp -rf output/* /opt/apisix-dashboard/

# create APISIX Dashboard systemd service
echo "Creating APISIX Dashboard systemd service"
sudo tee /etc/systemd/system/apisix-dashboard.service > /dev/null <<EOF
[Unit]
Description=apisix-dashboard
Conflicts=apisix-dashboard.service
After=network-online.target

[Service]
WorkingDirectory=/opt/apisix-dashboard
ExecStart=/opt/apisix-dashboard/manager-api -c /opt/apisix-dashboard/conf/conf.yaml
EOF

# Start and enable APISIX Dashboard service
echo "Starting APISIX Dashboard service"
sudo systemctl daemon-reload
sudo systemctl enable apisix-dashboard.service
sudo systemctl start apisix-dashboard.service
echo "APISIX Dashboard service status:"
sudo systemctl status apisix-dashboard.service --no-pager
sudo ss -plunt

echo "Installation completed successfully!"