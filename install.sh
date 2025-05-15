#!/bin/bash
set -e

# Download APISIX Dashboard
rm -rf /opt/apisix-dashboard
wget https://github.com/rhgenius/apisix-dashboard/releases/download/v3.0.1/executable.tar.gz
tar -xvf executable.tar.gz
mkdir -p /opt/apisix-dashboard
cp -rf output/* /opt/apisix-dashboard/

# Install APISIX
echo "Installing APISIX dependencies"
sudo apt-get update
sudo apt-get install -y gnupg

echo "Adding APISIX repository"
wget -qO - http://repos.apiseven.com/pubkey.gpg | sudo apt-key add -
echo "deb http://repos.apiseven.com/packages/debian bullseye main" | sudo tee /etc/apt/sources.list.d/apisix.list

echo "Installing APISIX"
sudo apt-get update
sudo apt-get install -y apisix=3.12.0-0

# Copy configuration and certificate file
cp -rf /opt/apisix-dashboard/conf/cert /usr/local/apisix/conf/

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

# Configure APISIX with etcd cluster
# Replace these IPs with your actual etcd cluster endpoints if needed
ETCD_ENDPOINTS=(
  "http://10.101.207.13:2379"
  "http://10.101.207.14:2379"
  "http://10.101.207.15:2379"

)

sudo tee /usr/local/apisix/conf/config.yaml > /dev/null <<EOF
apisix:
  node_listen:
    - port: 80
  enable_http2: true
  ssl:
    enable: true
    listen:
      - port: 443
        server_name: apisix.creditbureauindonesia.co.id
    cert: /usr/local/apisix/conf/cert/cert.creditbureauindonesia.co.id.pem
    key: /usr/local/apisix/conf/cert/key.creditbureauindonesia.co.id.pem
    ssl_protocols: TLSv1.2 TLSv1.3
    ssl_ciphers: ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
    ssl_session_tickets: false
deployment:
  role: traditional
  role_traditional:
    config_provider: etcd
  admin:
    admin_key:
      - name: admin
        key: I8uPoqWntUxR64K
        role: admin
  etcd:
    host:
$(for ep in "${ETCD_ENDPOINTS[@]}"; do echo "      - \"$ep\""; done)
EOF

# Start and enable APISIX service
echo "Starting APISIX service"
sudo systemctl daemon-reload
sudo systemctl enable apisix.service
sudo systemctl start apisix.service
echo "APISIX service status:"
sudo systemctl status apisix.service --no-pager

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

[Install]
WantedBy=multi-user.target
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