#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker logs $DOCKER_NAME > console.log

docker cp $DOCKER_NAME:/var/ton-work/logs/json-explorer.log .
docker cp $DOCKER_NAME:/var/ton-work/logs/blockchain-explorer.log .
docker cp $DOCKER_NAME:/var/ton-work/logs/participate.txt ./participate.log
docker cp $DOCKER_NAME:/var/ton-work/logs/reap.txt ./reap.log
