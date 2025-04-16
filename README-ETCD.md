# etcd Cluster Install & Uninstall Scripts

This guide explains how to use the provided scripts to **install**, **configure**, and **uninstall** an etcd cluster across multiple nodes. The workflow supports dynamic cluster formation: install etcd everywhere first, then form the cluster step-by-step.

---

## Prerequisites
- Linux (tested on Ubuntu/CentOS)
- sudo privileges on all nodes
- Basic networking between all cluster nodes (open ports 2379, 2380)
- wget installed

---

## Files
- `install_etcd_cluster.sh` — Installs etcd and configures the node for cluster participation.
- `uninstall_etcd_cluster.sh` — Completely removes etcd, its data, binaries, systemd service, and user.

---

## Installation & Cluster Formation

### 1. Install etcd on All Nodes
On **each node**, run:
```bash
./install_etcd_cluster.sh install
```
This will:
- Download and install the etcd binary
- Create the etcd user and data directory
- **Not** start etcd or configure the cluster yet

---

### 2. Start the First Node (Initial Cluster)
On your first node (e.g., etcd1):
```bash
ETCD_NAME=etcd1 \
ETCD_IP=192.168.64.32 \
ETCD_INITIAL_CLUSTER="etcd1=http://192.168.64.32:2380" \
ETCD_INITIAL_CLUSTER_STATE=new \
./install_etcd_cluster.sh join
```
- Replace `etcd1` and `192.168.64.32` with your actual hostname and IP.

---

### 3. Add Additional Nodes to the Cluster
On the first node, add each additional node using `etcdctl`:
```bash
etcdctl --endpoints=http://192.168.64.32:2379 member add etcd2 --peer-urls=http://192.168.64.33:2380
```
- Replace `etcd2` and `192.168.64.33` with your next node's name and IP.

The command will output environment variables similar to:
```
ETCD_NAME="etcd2"
ETCD_INITIAL_CLUSTER="etcd1=http://192.168.64.32:2380,etcd2=http://192.168.64.33:2380"
ETCD_INITIAL_CLUSTER_STATE="existing"
```

---

### 4. Start etcd on the New Node
On the new node (e.g., etcd2), use the output from the previous step:
```bash
ETCD_NAME=etcd2 \
ETCD_IP=192.168.64.33 \
ETCD_INITIAL_CLUSTER="etcd1=http://192.168.64.32:2380,etcd2=http://192.168.64.33:2380" \
ETCD_INITIAL_CLUSTER_STATE=existing \
./install_etcd_cluster.sh join
```
Repeat steps 3 and 4 for each additional node (etcd3, etcd4, etc.).

---

### 5. Verify Cluster Health
On any node, check cluster health:
```bash
etcdctl --endpoints=http://192.168.64.32:2379,http://192.168.64.33:2379,http://192.168.64.34:2379 endpoint health
```

---

## Uninstalling etcd
To completely remove etcd and all its data from a node, run:
```bash
./uninstall_etcd_cluster.sh
```
This will:
- Stop and disable the etcd service
- Remove the systemd service file
- Delete etcd binaries and data directory
- Remove the etcd user

---

## Notes & Tips
- Always use the environment variables output by `etcdctl member add` when joining new nodes.
- The scripts require sudo privileges for system modifications.
- You can safely run the install script multiple times; it will not overwrite existing data unless you uninstall first.
- If you need to reconfigure the cluster, uninstall etcd from all nodes and repeat the process.

---

## Troubleshooting
- If etcd fails to start, check logs with:
  ```bash
  sudo journalctl -xeu etcd
  ```
- Ensure all nodes can communicate over the required ports (2379, 2380).
- Make sure to use correct and consistent node names and IPs across all commands.

---

## References
- [Official etcd Clustering Guide](https://etcd.io/docs/v3.5/tutorials/how-to-setup-cluster/)

---

If you have any questions or need help, please open an issue or contact the maintainer.
