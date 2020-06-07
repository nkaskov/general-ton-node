#!/bin/bash

if [ -z "$1" ]; then
    echo "Specify wallet address"
    exit
fi

ADDR=$1

RES=$(lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -c "last" -c "getaccount ${ADDR}")

ACTIVE=$(echo $RES | grep "state:(account_active")
EMPTY=$(echo $RES | grep "account state is empty")
UNINIT=$(echo $RES | grep "state:account_uninit))")
BALANCE=$(lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -c "last" -c "getaccount ${ADDR}" | grep "account balance is " | cut -c 20-)

STATE="UNKNOWN" # frozen?

if [ ! -z "$ACTIVE" ]; then
    STATE="ACTIVE"
fi

if [ ! -z "$EMPTY" ]; then
    STATE="EMPTY"
fi

if [ ! -z "$UNINIT" ]; then
    STATE="UNINIT"
fi

if [ -z "$BALANCE" ]; then
    BALANCE=0
fi

#echo $RES

echo "Account state is $STATE with balance $BALANCE"
