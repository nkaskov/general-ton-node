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

docker cp $DOCKER_NAME:/var/ton-work/contracts/validator.hexaddr .
docker cp $DOCKER_NAME:/var/ton-work/contracts/validator.addr .
docker cp $DOCKER_NAME:/var/ton-work/contracts/validator.pk .

if [ "$GENESIS" == "1" ]; then
    docker cp $DOCKER_NAME:/var/ton-work/db/my-ton-global.config.json .
    docker cp $DOCKER_NAME:/var/ton-work/contracts/main-wallet.addr .
    docker cp $DOCKER_NAME:/var/ton-work/contracts/main-wallet.pk .
    docker cp $DOCKER_NAME:/var/ton-work/contracts/config-master.addr .
    docker cp $DOCKER_NAME:/var/ton-work/contracts/config-master.pk .
fi
