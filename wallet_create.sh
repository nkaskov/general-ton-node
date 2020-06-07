#!/bin/bash

if [ -z "$1" ]; then
    WALLET_NAME=validator
else
    WALLET_NAME=$1
fi

if [ -z "$2" ]; then
    CHAIN=-1
else
    CHAIN=$2
fi

if test -f "$WALLET_NAME.pk"; then
    echo -n "$WALLET_NAME exist! Do you wand to overwrite it? (y/n) "
    read answer
    if [ "$input" != "Y" ] && [ "$input" != "y" ]; then
        exit
    else
        echo "ok"
    fi
fi

rm -f "$WALLET_NAME.pk"
rm -f "$WALLET_NAME.addr"
rm -f "$WALLET_NAME.hexaddr"
rm -f "$WALLET_NAME-query.boc"

# create new wallet by validator
RES=$(fift -s /var/ton-work/contracts/new-wallet.fif $CHAIN $WALLET_NAME | grep "new wallet address" | cut -c 22-)
echo -n $RES >"$WALLET_NAME.hexaddr"

echo "Created new wallet in filebase ${WALLET_NAME} with address ${RES}"
# files:
# validator-query.boc
# validator.addr
# validator.pk
#