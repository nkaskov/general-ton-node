#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

if [ "$1" != "y" ]; then

    echo -n "This may overwrite existing files. Are you sure? (y/n): "
    read answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
        exit
    fi

fi

docker cp validator.hexaddr $DOCKER_NAME:/var/ton-work/contracts
docker cp validator.addr $DOCKER_NAME:/var/ton-work/contracts
docker cp validator.pk $DOCKER_NAME:/var/ton-work/contracts
