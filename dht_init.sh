#!/usr/bin/env bash

if [[ "$DHT_SERVER" == 1 ]]; then
    IP=$PUBLIC_IP; IPNUM=0; for (( i=0 ; i<4 ; ++i )); do ((IPNUM=$IPNUM+${IP%%.*}*$((256**$((3-${i})))))); IP=${IP#*.}; done
    [ $IPNUM -gt $((2**31)) ] && IPNUM=$(($IPNUM - $((2**32))))

    mkdir dht-server
    cd dht-server
    cp ../my-ton-global.config.json .
    cp ../example.config.json .
    dht-server -C example.config.json -D . -I "$PUBLIC_IP:$DHT_PORT"

    key=$(ls keyring | head -1)

    cp keyring/$key ./dht_key

    DHT_NODES=$(generate-random-id -m dht -k ./dht_key -a "{
                \"@type\": \"adnl.addressList\",
                \"addrs\": [
                {
                    \"@type\": \"adnl.address.udp\",
                    \"ip\":  $IPNUM,
                    \"port\": $DHT_PORT
                }
                ],
                \"version\": 0,
                \"reinit_date\": 0,
                \"priority\": 0,
                \"expire_at\": 0
            }")

    cd ..
    echo $DHT_NODES > ./dht_node.conf

    #sed -i -e "s#NODES#$(printf "%q" $DHT_NODES)#g" my-ton-global.config.json
    #cp my-ton-global.config.json ..
    #dht-server -C my-ton-global.config.json -D . -I "$PUBLIC_IP:$DHT_PORT"&
    #cd ..
fi