#!/bin/bash

if [ ! -f ./env.sh ]; then
    echo "env.sh not found!"
    exit 1
fi

. ./env.sh

if [ -z "$VOLUME_NAME" ]; then
  echo "No volume created"
else
  docker volume create $VOLUME_NAME
fi