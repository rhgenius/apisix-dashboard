#!/bin/bash

# Analyze SSL handshake errors
echo "Top SSL protocol/cipher combinations:"
grep -o '".*"' /usr/local/apisix/logs/ssl_access.log | sort | uniq -c | sort -nr

echo "\nFailed handshakes:"
grep '400' /usr/local/apisix/logs/ssl_access.log | tail -n 10

echo "\nDebugging errors:"
grep -i 'SSL' /usr/local/apisix/logs/ssl_error.log | tail -n 20
