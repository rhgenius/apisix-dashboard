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
  "host": "apisix-dashboard.creditbureauindonesia.co.id",
  "upstream_id": "1"
}'
```

Step 3: Configure SSL (HTTPS) via APISIX

```bash
# create cert and key variable
cert_content=$(cat /usr/local/apisix/conf/cert/cert.creditbureauindonesia.co.id.pem | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}')
key_content=$(cat /usr/local/apisix/conf/cert/key.creditbureauindonesia.co.id.pem | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}')

curl http://localhost:9180/apisix/admin/ssls/8881 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @- <<EOF
{
  "cert": "$cert_content",
  "key": "$key_content", 
  "snis": ["*.creditbureauindonesia.co.id","creditbureauindonesia.co.id"]
}
EOF

#==========================================================================
# h-sandbox.cbi.id
cert_content=$(cat /usr/local/apisix/conf/cert/fullchain.pem | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}')
key_content=$(cat /usr/local/apisix/conf/cert/key.cbi.id.pem | awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}')


# Apply SSL configuration globally
curl http://localhost:9180/apisix/admin/ssls/8881 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @- <<EOF
{
  "cert": "$cert_content",
  "key": "$key_content", 
  "snis": ["*.cbi.id","cbi.id"]
}
EOF

cd ../fastapi-app1/

# Apply upstream configuration (hello-world1)
curl http://localhost:9180/apisix/admin/upstreams/8881 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-upstream.json

# Apply route configuration (hello-world1)
curl http://localhost:9180/apisix/admin/routes/8881 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-route.json

cd ../fastapi-app2/

# Apply upstream configuration (hello-world2)
curl http://localhost:9180/apisix/admin/upstreams/8882 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-upstream.json

# Apply route configuration (hello-world2)
curl http://localhost:9180/apisix/admin/routes/8882 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-route.json

cd ../fastapi-app3/

# Apply upstream configuration (hello-world3)
curl http://localhost:9180/apisix/admin/upstreams/8883 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-upstream.json

# Apply route configuration (hello-world3)
curl http://localhost:9180/apisix/admin/routes/8883 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' \
-X PUT -d @apisix-route.json
```

Validate APISIX SSL Configuration
Step 1: List SSL Certificates in APISIX

```bash
curl http://localhost:9180/apisix/admin/ssls -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1'
```

Step 2: Test the SSL Handshake Manually

```bash
openssl s_client -connect h-sandbox-hello-world-01.cbi.id:443 -servername h-sandbox-hello-world-01.cbi.id
```

Step 3: Restart APISIX

```bash
systemctl restart apisix
```

Step 4: Test with curl

```bash
curl -v https://localhost -H 'Host: apisix-dashboard.rachmat.my.id' --resolve apisix-dashboard.rachmat.my.id:443:localhost
```
