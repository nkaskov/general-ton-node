#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

if [ -n "$DHT_PORT" ]; then
    docker cp $DOCKER_NAME:/var/ton-work/db/dht_node.conf .
fi

if [ -n "$LITE_PORT" ]; then
    docker cp $DOCKER_NAME:/var/ton-work/db/liteserver.conf .
    docker cp $DOCKER_NAME:/var/ton-work/db/liteserver.pub .
fi

if [ -n "$CONSOLE_PORT" ]; then
    docker cp $DOCKER_NAME:/var/ton-work/db/server.pub ./console_server.pub
    docker cp $DOCKER_NAME:/var/ton-work/db/client ./console_client
fi

