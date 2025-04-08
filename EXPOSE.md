Configure APISIX (OpenResty) to Route Traffic to the Dashboard

Step 1: Create an Upstream

```bash
curl http://localhost:9180/apisix/admin/upstreams/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
  "name": "dashboard-upstream",
  "nodes": {
    "localhost:9000": 1
  }
}'
```

Step 2: Create a Route

```bash
curl http://localhost:9180/apisix/admin/routes/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
  "name": "dashboard-route",
  "uri": "/*",
  "host": "apisix-dashboard.rachmat.my.id",
  "upstream_id": "1"
}'
```

Step 3: Configure SSL (HTTPS) via APISIX

```bash
curl http://localhost:9180/apisix/admin/ssls/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
  "cert": "'"$(cat /opt/apisix-dashboard/cert/apisix-dashboard.pem)"'",
  "key": "'"$(cat /opt/apisix-dashboard/cert/apisix-dashboard-key.pem)"'",
  "snis": ["apisix-dashboard.rachmat.my.id"]
}'
```

Validate APISIX SSL Configuration
Step 1: List SSL Certificates in APISIX

```bash
curl http://localhost:9180/apisix/admin/ssls -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'
```

Step 2: Test the SSL Handshake Manually

```bash
openssl s_client -connect apisix-dashboard.rachmat.my.id:443 -servername apisix-dashboard.rachmat.my.id
```

Step 3: Restart APISIX

```bash
systemctl restart apisix
```

Step 4: Test with curl

```bash
curl -v https://127.0.0.1 -H 'Host: apisix-dashboard.rachmat.my.id' --resolve apisix-dashboard.rachmat.my.id:443:127.0.0.1
```
