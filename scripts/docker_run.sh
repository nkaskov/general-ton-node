#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

if [ ! -n "$GENESIS" ]; then
    GENESIS=0
fi

if [ "$GENESIS" -eq "0" ]; then
    if [ ! -n "$CONFIG" ]; then
        echo "No global config"
        exit 1
    fi
else
    CONFIG=""
fi

if [ -n "$HTTP_PORT" ]; then
    SERVECONFIG=1
else
    SERVECONFIG=0
fi

if [ ! -n "$PUBLIC_IP" ]; then
    echo "No pulbic IP set, using 127.0.0.1"
    PUBLIC_IP=127.0.0.1
fi

if [ ! -n "$BIND_IP" ]; then
    echo "No bind IP set, using 0.0.0.0"
    BIND_IP=0.0.0.0
fi

if [ -n "$DHT_PORT" ]; then
    DHT_SERVER=1
else
    echo "No DHT server"
    DHT_SERVER=0
fi

if [ -n "$LITE_PORT" ]; then
    LITESERVER=true
else
    echo "No Lite server"
    LITESERVER=false
fi

if [ ! -n "$ADNL_PORT" ]; then
    echo "No ADNL port set, using 30310"
    ADNL_PORT=30310
fi

if [ ! -n "$CONSOLE_PORT" ]; then
    echo "No Console port set, using 50000"
    CONSOLE_PORT=50000
fi

if [ -n "$JSON_EXPLORER_PORT" ]; then
    JSON_EXPLORER=1
else
    echo "No JSON explorer"
    JSON_EXPLORER=0
fi

if [ -n "$BLOCK_EXPLORER_PORT" ]; then
    BLOCK_EXPLORER=1
else
    echo "No Blockchain explorer"
    BLOCK_EXPLORER=0
fi

echo "Run cmd: docker run -d --name $DOCKER_NAME --mount source=$VOLUME_NAME,target=/var/ton-work --network host \
    -e \"GENESIS=$GENESIS\" -e \"SANDBOX=$SANDBOX\" -e \"SERVECONFIG=$SERVECONFIG\" -e \"HTTPPORT=$HTTP_PORT\" \
    -e \"CONFIG=$CONFIG\" \
    -e \"PUBLIC_IP=$PUBLIC_IP\" -e \"BIND_IP=$BIND_IP\" \
    -e \"DHT_SERVER=$DHT_SERVER\" -e \"DHT_PORT=$DHT_PORT\" \
    -e \"LITESERVER=$LITESERVER\" -e \"LITE_PORT=$LITE_PORT\" \
    -e \"PUBLIC_PORT=$ADNL_PORT\" -e \"CONSOLE_PORT=$CONSOLE_PORT\" \
    -e \"JSON_EXPLORER=$JSON_EXPLORER\" -e \"JSON_PORT=$JSON_EXPLORER_PORT\" \
    -e \"BLOCK_EXPLORER=$BLOCK_EXPLORER\" -e \"BLOCK_PORT=$BLOCK_EXPLORER_PORT\" \
    -it $IMAGE_NAME"

docker run -d --name $DOCKER_NAME --mount source=$VOLUME_NAME,target=/var/ton-work --network host \
    -e "GENESIS=$GENESIS" -e "SANDBOX=$SANDBOX" -e "SERVECONFIG=$SERVECONFIG" -e "HTTPPORT=$HTTP_PORT" \
    -e "CONFIG=$CONFIG" \
    -e "PUBLIC_IP=$PUBLIC_IP" -e "BIND_IP=$BIND_IP" \
    -e "DHT_SERVER=$DHT_SERVER" -e "DHT_PORT=$DHT_PORT" \
    -e "LITESERVER=$LITESERVER" -e "LITE_PORT=$LITE_PORT" \
    -e "PUBLIC_PORT=$ADNL_PORT" -e "CONSOLE_PORT=$CONSOLE_PORT" \
    -e "JSON_EXPLORER=$JSON_EXPLORER" -e "JSON_PORT=$JSON_EXPLORER_PORT" \
    -e "BLOCK_EXPLORER=$BLOCK_EXPLORER" -e "BLOCK_PORT=$BLOCK_EXPLORER_PORT" \
    -it $IMAGE_NAME

