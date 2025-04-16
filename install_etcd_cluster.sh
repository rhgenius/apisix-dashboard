#!/bin/bash
# install_etcd_cluster.sh
# Usage:
#   ./install_etcd_cluster.sh install
#   ETCD_NAME=etcd1 ETCD_IP=192.168.1.11 ETCD_INITIAL_CLUSTER="etcd1=http://192.168.1.11:2380" ETCD_INITIAL_CLUSTER_STATE=new ./install_etcd_cluster.sh join
#   (for joining: use env vars as provided by `etcdctl member add`)

set -e

# Configurable parameters
ETCD_VERSION="v3.5.14"
DOWNLOAD_URL="https://github.com/etcd-io/etcd/releases/download"
INSTALL_DIR="/usr/local/bin"
DATA_DIR="/var/lib/etcd"
USER="etcd"

MODE="$1"

if [[ "$MODE" != "install" && "$MODE" != "join" ]]; then
  echo "Usage: $0 <install|join>"
  exit 1
fi

if [[ "$MODE" == "install" ]]; then
  # 1. Download and install etcd
  if ! command -v etcd >/dev/null 2>&1; then
    echo "Downloading etcd $ETCD_VERSION..."
    wget -q $DOWNLOAD_URL/$ETCD_VERSION/etcd-$ETCD_VERSION-linux-amd64.tar.gz
    tar xzf etcd-$ETCD_VERSION-linux-amd64.tar.gz
    sudo mv etcd-$ETCD_VERSION-linux-amd64/etcd* $INSTALL_DIR/
    rm -rf etcd-$ETCD_VERSION-linux-amd64*
  fi
  echo "etcd installed at $INSTALL_DIR/etcd"

  # 2. Create etcd user and data dir
  if ! id "$USER" >/dev/null 2>&1; then
    sudo useradd -r -s /sbin/nologin -M $USER
  fi
  sudo mkdir -p $DATA_DIR
  sudo chown -R $USER:$USER $DATA_DIR
  echo "Install step complete. Now run this script with 'join' to configure and start etcd."
  exit 0
fi

# --- join mode ---
# Required environment variables
: "${ETCD_NAME:?Need to set ETCD_NAME, e.g. etcd1}"
: "${ETCD_IP:?Need to set ETCD_IP, e.g. 192.168.1.11}"
: "${ETCD_INITIAL_CLUSTER:?Need to set ETCD_INITIAL_CLUSTER, e.g. etcd1=http://192.168.1.11:2380,etcd2=http://192.168.1.12:2380}"
: "${ETCD_INITIAL_CLUSTER_STATE:?Need to set ETCD_INITIAL_CLUSTER_STATE, e.g. new or existing}"

SERVICE_FILE="/etc/systemd/system/etcd.service"
cat <<EOF | sudo tee $SERVICE_FILE
[Unit]
Description=etcd key-value store
Documentation=https://etcd.io
After=network.target
Wants=network-online.target

[Service]
User=$USER
Type=notify
ExecStart=$INSTALL_DIR/etcd \\
  --name $ETCD_NAME \\
  --data-dir $DATA_DIR \\
  --listen-peer-urls http://$ETCD_IP:2380 \\
  --listen-client-urls http://$ETCD_IP:2379,http://127.0.0.1:2379 \\
  --advertise-client-urls http://$ETCD_IP:2379 \\
  --initial-advertise-peer-urls http://$ETCD_IP:2380 \\
  --initial-cluster $ETCD_INITIAL_CLUSTER \\
  --initial-cluster-state $ETCD_INITIAL_CLUSTER_STATE \\
  --initial-cluster-token etcd-cluster-1
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl restart etcd

echo "etcd cluster node $ETCD_NAME started on $ETCD_IP with cluster state $ETCD_INITIAL_CLUSTER_STATE."