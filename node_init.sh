#!/usr/bin/env bash

# Init local config with IP:PORT
if [ ! -z "$PUBLIC_IP" ]; then
    if [ -z "$CONSOLE_PORT" ]; then
        CONSOLE_PORT="43678"
    fi
    echo -e "\e[1;32m[+]\e[0m Using provided IP: $PUBLIC_IP:$CONSOLE_PORT"
    #validator-engine -C /var/ton-work/db/my-ton-global.config.json --db /var/ton-work/db --ip "$PUBLIC_IP:$PUBLIC_PORT"
    if [[ "$DHT_SERVER" == 1 ]]; then
        validator-engine -C /var/ton-work/db/my-ton-global.config.json --db /var/ton-work/db --ip "$PUBLIC_IP:$PUBLIC_PORT"
    else
        validator-engine -C /var/ton-work/db/example.config.json --db /var/ton-work/db --ip "$PUBLIC_IP:$PUBLIC_PORT"

        echo "Generated keys:"
        ls keyring/

        echo "Initial config:"
        cat config.json

        DHT_KEY=$(python -c "f = open('config.json', 'r'); import json; j = json.load(f); k = j['dht'][0]['id']; import base64; import codecs; print('%064X' % int(codecs.encode(base64.b64decode(k), 'hex'), 16))")
        echo "DHT key: $DHT_KEY"

        IP=$PUBLIC_IP; IPNUM=0; for (( i=0 ; i<4 ; ++i )); do ((IPNUM=$IPNUM+${IP%%.*}*$((256**$((3-${i})))))); IP=${IP#*.}; done
        [ $IPNUM -gt $((2**31)) ] && IPNUM=$(($IPNUM - $((2**32))))

        DHT_NODES=$(generate-random-id -m dht -k /var/ton-work/db/keyring/$DHT_KEY -a "{
                    \"@type\": \"adnl.addressList\",
                    \"addrs\": [
                    {
                        \"@type\": \"adnl.address.udp\",
                        \"ip\":  $IPNUM,
                        \"port\": $PUBLIC_PORT
                    }
                    ],
                    \"version\": 0,
                    \"reinit_date\": 0,
                    \"priority\": 0,
                    \"expire_at\": 0
                }")
        echo $DHT_NODES > ./dht_node.conf
    fi

else
    echo -e "\e[1;31m[!]\e[0m No IP:PORT provided, exiting"
    exit 1
fi
# Generating server certificate
if [ -f "./server" ]; then
    echo -e "\e[1;33m[=]\e[0m Found existing server certificate, skipping"
else 
    echo -e "\e[1;32m[+]\e[0m Generating and installing server certificate for remote control"
    read -r SERVER_ID1 SERVER_ID2 <<< $(generate-random-id -m keys -n server)
    echo "Server IDs: $SERVER_ID1 $SERVER_ID2"
    cp server /var/ton-work/db/keyring/$SERVER_ID1
fi

# Generating client certificate
if [ -f "./client" ]; then 
    echo -e "\e[1;33m[=]\e[0m Found existing client certificate, skipping"
else
    read -r CLIENT_ID1 CLIENT_ID2 <<< $(generate-random-id -m keys -n client)
    echo -e "\e[1;32m[+]\e[0m Generated client private certificate $CLIENT_ID1 $CLIENT_ID2"
    echo -e "\e[1;32m[+]\e[0m Generated client public certificate"
    # Adding client permissions
    sed -e "s/CONSOLE-PORT/\"$(printf "%q" $CONSOLE_PORT)\"/g" -e "s~SERVER-ID~\"$(printf "%q" $SERVER_ID2)\"~g" -e "s~CLIENT-ID~\"$(printf "%q" $CLIENT_ID2)\"~g" control.template > control.new
    sed -e "s~\"control\"\ \:\ \[~$(printf "%q" $(cat control.new))~g" config.json > config.json.new
    mv config.json.new config.json
fi

