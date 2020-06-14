#!/usr/bin/env bash

while [ 1 = 1 ]
do
json-explorer -l /var/ton-work/logs/json-explorer.log -H $JSON_PORT  -p /var/ton-work/db/liteserver.pub -a "127.0.0.1:$LITE_PORT"
date -u  >> /var/ton-work/logs/json-explorer.log
echo "json-explorer exited" >> /var/ton-work/logs/json-explorer.log
done
