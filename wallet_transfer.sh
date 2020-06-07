#!/bin/bash

if [ -z "$1" ]; then
    echo "Specify walletbase"
    exit
fi

BASE=$1

if [ -z "$2" ]; then
    echo "Specify source address"
    exit
fi

SRC=$2

if [ -z "$3" ]; then
    echo "Specify destination address"
    exit
fi

DST=$3

if [ -z "$4" ]; then
    echo "Specify amount in ROCKS"
    exit
fi

AMOUNT=$4

SEQNUM=$(lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -c "getaccount $SRC" |grep 'x{'| tail -n1 |cut -c 4-|cut -c -8)

rm -f wallet-query.boc

fift -s /var/ton-work/contracts/wallet.fif $BASE $DST 0x${SEQNUM} $AMOUNT -n >/dev/null
# fift -s wallet.fif main-wallet -1:2bb5caef99ccfe7ac6b36d9dccdad843d49127fc1784543ee002ccb6892a773b 0x00000003 40000. -n
# fift -s wallet.fif main-wallet -1:d2482f9abed79cdd46ce42f7a73f2306e7e0a63a9c191cda5620a5e9ddd2c162 0x00000002 40000. -n

if test -f "wallet-query.boc"; then

    echo "Sending ${AMOUNT} ROCKS to ${DST} SEQNUM ${SEQNUM}"

    # -> wallet-query.boc
    lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -c "sendfile wallet-query.boc"

    echo "Done"

fi
