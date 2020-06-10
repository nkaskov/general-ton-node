#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker cp $DOCKER_NAME:/var/ton-work/logs/node.log ./node.log
