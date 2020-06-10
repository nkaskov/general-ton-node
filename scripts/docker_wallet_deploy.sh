#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker exec -it $DOCKER_NAME bash -c "cd /var/ton-work/contracts && wallet_deploy.sh validator"

