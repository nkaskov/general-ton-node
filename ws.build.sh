#!/bin/bash

if [ ! -f ./scripts/env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./scripts/env.sh

docker build -t ton-rocks-ws -f Dockerfile.ws . --build-arg core_count=${CORE_COUNT} --build-arg ton_repo=${TON_REPO} --build-arg ton_commit=${TON_COMMIT}
