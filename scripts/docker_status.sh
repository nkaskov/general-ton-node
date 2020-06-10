#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker exec -it $DOCKER_NAME validator-engine-console -a 127.0.0.1:$CONSOLE_PORT -k client -p server.pub -c "getstats" -c "quit"
