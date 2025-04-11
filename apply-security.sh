#!/bin/bash

# Apply SSL and security configurations
sudo cp config/ssl-config.yaml /usr/local/apisix/conf/
sudo cp config/limit-req.yaml /usr/local/apisix/conf/

# Restart APISIX with new config
sudo apisix stop
sudo apisix start

# Verify configuration
curl -v https://localhost 2>&1 | grep 'SSL handshake'

# Monitor logs
tail -f /usr/local/apisix/logs/error.log | grep --line-buffered 'SSL'
