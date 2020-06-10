#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

if [ "$1" != "y" ]; then
    echo -n "Do you want to stop and delete node? (y/n): "
    read answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
       exit
    fi
fi

docker stop $DOCKER_NAME
docker rm $DOCKER_NAME

if [ "$2" == "n" ]; then
    exit
fi

if [ "$2" != "y" ]; then
    echo -n "Do you want to delete permanent storage? (y/n): "
    read answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
        exit
    fi
fi

docker volume rm $VOLUME_NAME

if [ "$3" == "n" ]; then
    exit
fi

if [ "$3" != "y" ]; then
    echo -n "Do you want to delete image? (y/n): "
    read answer
    if [ "$answer" != "Y" ] && [ "$answer" != "y" ]; then
       exit
    fi
fi

docker rmi $IMAGE_NAME

