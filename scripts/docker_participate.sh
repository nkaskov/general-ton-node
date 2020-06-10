#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker exec -t $DOCKER_NAME bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
docker exec -t $DOCKER_NAME bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"

