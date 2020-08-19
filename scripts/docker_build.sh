#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

docker build -t $IMAGE_NAME $REPO_PATH --build-arg core_count=${CORE_COUNT} --build-arg ton_repo=${TON_REPO} --build-arg ton_commit=${TON_COMMIT}
