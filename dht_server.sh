
#!/usr/bin/env bash

while [ 1 = 1 ]
do
dht-server -l /var/ton-work/logs/dht-server.log -C my-ton-global.config.json -D . -I "$BIND_IP:$DHT_PORT"
date -u  >> /var/ton-work/logs/dht-server.log
echo "dht-server exited" >> /var/ton-work/logs/dht-server.log
done
