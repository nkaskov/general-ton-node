#!/usr/bin/env bash

while [ 1 = 1 ]
do
ws-tcp-proxy.py -l 127.0.0.1 -p $LITE_PORT -b $BIND_IP -d $WS_PORT  >> /var/ton-work/logs/ws-proxy.log 2>&1
date -u  >> /var/ton-work/logs/ws-proxy.log
echo "ws proxy exited" >> /var/ton-work/logs/ws-proxy.log
done
