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
cat > cert.pem <<EOF
-----BEGIN CERTIFICATE-----
MIIGYjCCBUqgAwIBAgIQNbz+XFRPZXvByYCfTf+OZTANBgkqhkiG9w0BAQsFADCB
jzELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4G
A1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMTcwNQYDVQQD
Ey5TZWN0aWdvIFJTQSBEb21haW4gVmFsaWRhdGlvbiBTZWN1cmUgU2VydmVyIENB
MB4XDTIzMDgwMTAwMDAwMFoXDTI0MDgxNzIzNTk1OVowKDEmMCQGA1UEAwwdKi5j
cmVkaXRidXJlYXVpbmRvbmVzaWEuY28uaWQwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQC+92b4YRnF4Lsp4G1W0Ju7eIa97+TW0dIxnHfodXr+4Wt+6r13
8uUhvK/MrQi6KVOqq3SHctlBWMdcPndr/Mu11eNG865dqC/FyR2vU2qyePyOEaHB
fAnnOOlDji8kQMLU6imM5NEO3KBZrd9/CN07c3m8plvlttWcgj6SV/boab1fE3ZC
QIsAwRBHrqE4Knv720yahl7xVXBCLqoK8CiNjB4cdK4oIXgauh6pcGmz9fQIWouj
Y7TvVl9tLydDUSehXpl7U/bnRIut2sojO5W9djAFqj94yx6MwcZu/Zks3EkrYggq
KY9b+ZayqNL+UG+QnpZWJwNRF7cel4uJR2s/AgMBAAGjggMeMIIDGjAfBgNVHSME
GDAWgBSNjF7EVK2K4Xfpm/mbBeG4AY1h4TAdBgNVHQ4EFgQUNS9BBKN9rwU/diKT
khoYvtfUi0gwDgYDVR0PAQH/BAQDAgWgMAwGA1UdEwEB/wQCMAAwHQYDVR0lBBYw
FAYIKwYBBQUHAwEGCCsGAQUFBwMCMEkGA1UdIARCMEAwNAYLKwYBBAGyMQECAgcw
JTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwCAYGZ4EMAQIB
MIGEBggrBgEFBQcBAQR4MHYwTwYIKwYBBQUHMAKGQ2h0dHA6Ly9jcnQuc2VjdGln
by5jb20vU2VjdGlnb1JTQURvbWFpblZhbGlkYXRpb25TZWN1cmVTZXJ2ZXJDQS5j
cnQwIwYIKwYBBQUHMAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMEUGA1UdEQQ+
MDyCHSouY3JlZGl0YnVyZWF1aW5kb25lc2lhLmNvLmlkghtjcmVkaXRidXJlYXVp
bmRvbmVzaWEuY28uaWQwggGABgorBgEEAdZ5AgQCBIIBcASCAWwBagB2AHb/iD8K
tvuVUcJhzPWHujS0pM27KdxoQgqf5mdMWjp0AAABibEMwMwAAAQDAEcwRQIgQ7Ug
s9qNqr1eveAMgDZ9N/15/oc7b+IgzvOFJwm+DLQCIQDiAsDwXakElm8gxdkX4A/7
bIElr0f5QZlnK1AKJr6PDQB3ANq2v2s/tbYin5vCu1xr6HCRcWy7UYSFNL2kPTBI
1/urAAABibEMwScAAAQDAEgwRgIhAMQuuOFN7+cPAJGmUIx0C+VlZeUF+CBvdFI2
EFvOkHdeAiEAooWgFMd8io4U7Ro2TyYBv4PyomRd1DTUVsut69ysB+4AdwDuzdBk
1dsazsVct520zROiModGfLzs3sNRSFlGcR+1mwAAAYmxDMD2AAAEAwBIMEYCIQDZ
6/WEZag2SU4CYtfjbd9RLsNHBdSZch9jgYf0wZtc+wIhAP88Hqo4uqYV13vsar1B
6d/wHdSb9IqFv8S9wo+Mme4oMA0GCSqGSIb3DQEBCwUAA4IBAQBzkmE45VdeKWMa
du5mNTNULws1eVQx1hmvF+YmADDJ/gm/87T3y+0O8jF4YSWf6XNaZ6BawoFlm1qO
HdI/TTEuwNFiSu+hP6B0//nNdfJLgmtJsrSt3+3fljZQ0fZXUzTyy8iGuE1r/n6Q
/hTfDX+L5KskHZsnAx5AZTPz870YHbRpMXo7A7kY1Gl05Hbh194ioTwM1AA58Ph8
uUJi1UiV64pbC6n3slJzWMpODfKvH3NK7gZjuu0SjjdjiYrPCtF8YTIYQw6REgwi
jS1zdlZrZ++1Sh25C/I05wKzo5YyhP0OQO7z9JBSYjDCPAacgBdYmdOG85LyAn+y
/6fGbjmt
-----END CERTIFICATE-----
EOF
```

```bash
cat > key.pem <<EOF
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQC+92b4YRnF4Lsp
4G1W0Ju7eIa97+TW0dIxnHfodXr+4Wt+6r138uUhvK/MrQi6KVOqq3SHctlBWMdc
Pndr/Mu11eNG865dqC/FyR2vU2qyePyOEaHBfAnnOOlDji8kQMLU6imM5NEO3KBZ
rd9/CN07c3m8plvlttWcgj6SV/boab1fE3ZCQIsAwRBHrqE4Knv720yahl7xVXBC
LqoK8CiNjB4cdK4oIXgauh6pcGmz9fQIWoujY7TvVl9tLydDUSehXpl7U/bnRIut
2sojO5W9djAFqj94yx6MwcZu/Zks3EkrYggqKY9b+ZayqNL+UG+QnpZWJwNRF7ce
l4uJR2s/AgMBAAECggEBAKVz2o4GKvtLez2MCY93DAaAJVW42+7XOaLsKuOHrbnY
+naq0N903dq+DR5rKK2KEshC5qJX+i1oysl8AaHZE3IGz3RwujjA+CsH1aVKw52/
vykj0568ZiQkJc33CZcCWQt5mehNc2fJ9U/dmk8JEgxpPycYh3ReVXLVUXsfpXe0
bXDLiLlcfXwClYm7s/nvzjAZzIsWFWHt0LWX57sY7HiHQaePpgltn9THQ2tBD2bq
xlJuifDagFEyK8xrSeWLTvdGgcRhWckJs1I0flOqaD1Gq8DHaUUa69of7+V8tNoe
mZx+twYsBbVWWMuP78B6Jus6Ltc22STJvzgxNmhkWIkCgYEA7I+4ga03LfeMmq92
QKZ7DrxDYFuQ/1B7mClrn0R7CzEDzpwmGkVf7ltqMpOV16ipCtEwvuK0ZqcJwfWZ
GQKFt1rrU0a7RRAnn4iEBSlJkoqYU5z1W+H27iNVKzCeegyRbtg/+VOZPWxFS9KR
yx4eYagP89OMNNjTz+sdUNnWddUCgYEAzqiM4XiM818Ocf7Pqt363P5GDJYWgTiy
srEjm/kbq+gATgcZA250eOWkuiadSrSYgBIV6TICfN7h9fsYfbpO5q49T6tegtdm
OtfQtI40qtZIsgkevZRroaqYpn2VTu5bsGBzJ8n5xWYRJmWnCE6FKux6qV/51zRZ
U+XjSzYAAsMCgYEAjfCSWaSwNjGRuQLM5m+96JKHrtpiPv9wmVVJERBK7+UiDqdc
qWi07dUF/IDXaMX3X9ky8WYfrnRNg4a0rO/5gZHZH2eSWBcgXzXPWTVzwqzMR2cn
RVFpE2w53ydV/49o9+RjRlul19gOIDehaQmSWzA3Gir1toPfW6MMPQXoC10CgYAi
g1Gr4hcgGfLupNCHx7S6rZiDR5mQkSh+4UiCJvMxHXjXjyXlRdAb1LZTBFnmfQyu
7tZL8LcrpYl1LC8l6DR/IABLSuJo1ZJUJ3DKhqlTEqBnY1CH9r6W7Ee8HmMOII6d
gS4aKggVqHsav4VKxNpGleHSYZ33C94TPeRczjLoQwKBgHLMIeUhEz0BkSOmjV1m
0lXyZHGlBSq/NUcD5b4xEiMciDuEtqn7LvSPQ+2k9wSW0zVRVNrKnP1TTwHQONcH
Licz+4TeP2MdbHMU3s4NKhuZibUi3Lhcd/Hsrrwf1ynvBMYjOWSjqTR/wZ1sYvST
A6Cn99drVLAPgWcFklqFfxXy
-----END PRIVATE KEY-----
EOF
```

```bash
curl http://localhost:9180/apisix/admin/ssls/1 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d "$(cat <<EOF
{
  "cert": "$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' cert.pem)",
  "key": "$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' key.pem)",
  "snis": ["creditbureauindonesia.co.id", "*.creditbureauindonesia.co.id"]
}
EOF
)"
```

<!-- use this command if you have already created the certificate -->
```bash
curl http://localhost:9180/apisix/admin/ssls -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
  "id": "creditbureauindonesia-ssl",
  "snis": ["*.creditbureauindonesia.co.id", "creditbureauindonesia.co.id"],
  "cert": "'"$(cat /usr/local/apisix/conf/cert/STAR_creditbureauindonesia_co_id.pem)"'",
  "key": "'"$(cat /usr/local/apisix/conf/cert/creditbureauindonesia.co.id.pem)"'"
}'
```

```bash
curl http://localhost:9180/apisix/admin/ssls/1 \
-H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d "$(cat <<EOF
{
  "cert": "$(cat /usr/local/apisix/conf/cert/STAR_creditbureauindonesia_co_id.crt | awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}')",
  "key": "$(cat /usr/local/apisix/conf/cert/creditbureauindonesia.co.id.key | awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}')", 
  "snis": ["apisix-dashboard.creditbureauindonesia.co.id"]
}
EOF
)"
```

```bash
curl http://localhost:9180/apisix/admin/ssls/1 -H 'X-API-KEY: edd1c9f034335f136f87ad84b625c8f1' -X PUT -d '
{
  "cert": "'"$(cat /opt/apisix-dashboard/cert/apisix-dashboard.pem)"'",
  "key": "'"$(cat /opt/apisix-dashboard/cert/apisix-dashboard-key.pem)"'",
  "snis": ["apisix-dashboard.rachmat.my.id"]
}'
```

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
openssl s_client -connect apisix-dashboard.rachmat.my.id:443 -servername apisix-dashboard.rachmat.my.id
```

Step 3: Restart APISIX

```bash
systemctl restart apisix
```

Step 4: Test with curl

```bash
curl -v https://localhost -H 'Host: apisix-dashboard.rachmat.my.id' --resolve apisix-dashboard.rachmat.my.id:443:localhost
```
