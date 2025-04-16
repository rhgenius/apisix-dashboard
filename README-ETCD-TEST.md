# etcd Cluster Testing Guide

This guide explains how to test your etcd cluster for health, failover, data consistency, quorum behavior, and APISIX integration. Use these steps after setting up your cluster to ensure it is reliable and production-ready.

---

## 1. Cluster Health Check

Check the health of all nodes:
```bash
etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379,http://10.67.2.102:2379 endpoint health
```
Expected: All endpoints report `is healthy`.

---

## 2. Data Consistency Test

Write a key-value pair and read it from each node:
```bash
etcdctl --endpoints=http://10.67.1.122:2379 put foo bar
etcdctl --endpoints=http://10.67.2.181:2379 get foo
etcdctl --endpoints=http://10.67.1.157:2379 get foo
etcdctl --endpoints=http://10.67.2.102:2379 get foo
```
Expected: All nodes return `bar`.

---

## 3. Simulate Node Failure (Failover Test)

A. Stop one node (simulate failure):
```bash
# On the node you want to stop, e.g. etcd2:
sudo systemctl stop etcd
```

B. Check cluster health and quorum:
```bash
etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379,http://10.67.2.102:2379 endpoint health
```
Expected: Three nodes healthy, one unhealthy. Cluster remains operational (quorum is 3/4).

C. Try write/read operation:
```bash
etcdctl --endpoints=http://10.67.1.122:2379 put testkey testvalue
etcdctl --endpoints=http://10.67.2.102:2379 get testkey
```
Expected: Write and read succeed.

D. Restart the stopped node:
```bash
sudo systemctl start etcd
```
Check health again to confirm all nodes recover.

---

## 4. Simulate Loss of Quorum (APISIX-Aligned)

Stop three nodes (e.g., etcd2, etcd3, etcd4):
```bash
sudo systemctl stop etcd   # on etcd2
sudo systemctl stop etcd   # on etcd3
sudo systemctl stop etcd   # on etcd4
```

Try to write a key using the remaining node:
```bash
etcdctl --endpoints=http://10.67.1.122:2379 put failkey failvalue
```
Expected: Operation fails with a quorum error (`timeout` or `not enough started members`).

**APISIX Test:**
Try to create or update a route/service using the APISIX Admin API or Dashboard. Example (replace `<APISIX_ADMIN_HOST>` and `<admin_key>` as needed):

```bash
curl -X PUT "http://<APISIX_ADMIN_HOST>:9180/apisix/admin/routes/1" \
  -H "X-API-KEY: <admin_key>" \
  -H "Content-Type: application/json" \
  -d '{
        "uri": "/test",
        "upstream": {
          "type": "roundrobin",
          "nodes": {
            "127.0.0.1:1980": 1
          }
        }
      }'
```
Expected: APISIX returns an error (etcd unavailable/quorum lost).

---

## 5. Restore All Nodes

Start the stopped nodes:
```bash
sudo systemctl start etcd   # on etcd2
sudo systemctl start etcd   # on etcd3
sudo systemctl start etcd   # on etcd4
```

Check health and confirm all nodes are back and data is consistent:
```bash
etcdctl --endpoints=http://10.67.1.122:2379,http://10.67.2.181:2379,http://10.67.1.157:2379,http://10.67.2.102:2379 endpoint health
etcdctl --endpoints=http://10.67.2.102:2379 get foo
```

**APISIX Test:**
Retry the same Admin API or Dashboard operation as above. 
Expected: APISIX should now be able to read/write to etcd and configuration changes should succeed.

---

## 6. Remove and Re-add a Member (Optional)

Remove a member from a healthy node:
```bash
etcdctl --endpoints=http://10.67.1.122:2379 member list
etcdctl --endpoints=http://10.67.1.122:2379 member remove <member-id>
```
Re-add as before to test cluster membership change.

---

## 7. Monitor Logs

On each node, monitor logs for errors or warnings:
```bash
sudo journalctl -xeu etcd
```

---

## Notes
- Always ensure a majority (quorum) of nodes are running for the cluster to be operational.
- If a node is not healthy, check its logs and network connectivity.
- All tests assume your endpoints are:
  - etcd1: 10.67.1.122
  - etcd2: 10.67.2.181
  - etcd3: 10.67.1.157
  - etcd4: 10.67.2.102
  - APISIX Admin API: http://<APISIX_ADMIN_HOST>:9180 (change as needed)
- APISIX relies on etcd for all configuration/state. If etcd loses quorum, APISIX cannot update or read config.
- Always confirm APISIX is fully functional (e.g., can add/remove routes, plugins, upstreams) after any etcd failover or recovery.

---

If you have questions or encounter issues, check the logs and consult the [etcd documentation](https://etcd.io/docs/v3.5/) and [APISIX documentation](https://apisix.apache.org/docs/).
