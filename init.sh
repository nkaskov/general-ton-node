#!/usr/bin/env bash
set -x

if [ ! -d /var/ton-work/contracts ]; then
  cp -r /var/ton-work-copy/* /var/ton-work
fi

cd /var/ton-work/db

cron &

if [ -z "$PUBLIC_IP" ]; then
        export PUBLIC_IP=127.0.0.1
fi
if [ -z "$CONSOLE_PORT" ]; then
        export CONSOLE_PORT=50001
fi
if [ -z "$PUBLIC_PORT" ]; then
        export PUBLIC_PORT=50000
fi

if ( [ -d "state" ] && [ "$(ls -A ./state)" ]); then
  echo "Found non-empty state; Skip initialization";
  wget -O my-ton-global.config.json ${CONFIG}
  cat ${CONFIG}
else
  echo "Initializing network";
  ./prepare_network.sh
fi

if [[ "$SERVECONFIG" == 1 ]]; then
   echo "Serving config"
   python -m SimpleHTTPServer "$HTTPPORT" &
fi

if [[ "$DHT_SERVER" == 1 ]]; then
   echo "Start DHT server on $BIND_IP:$DHT_PORT"
   cd dht-server

   IP=$PUBLIC_IP; IPNUM=0; for (( i=0 ; i<4 ; ++i )); do ((IPNUM=$IPNUM+${IP%%.*}*$((256**$((3-${i})))))); IP=${IP#*.}; done
   [ $IPNUM -gt $((2**31)) ] && IPNUM=$(($IPNUM - $((2**32))))

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

   dht_server.sh &
   cd ..
   echo $DHT_NODES > ./dht_node.conf
else
  DHT_KEY=$(python -c "f=open('config.json', 'r'); import json; j=json.load(f); k=j['dht'][0]['id']; import base64; import codecs; print('%064X' % int(codecs.encode(base64.b64decode(k), 'hex'), 16))")
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

if [ ! -z "$LITESERVER" ]; then

   cd /var/ton-work/db
   LITESERVER_PUB=$(python -c 'import codecs; f=open("liteserver.pub", "rb+"); pub=f.read()[4:]; print(codecs.encode(pub,"base64").replace("\n",""))')
   IP=$PUBLIC_IP; IPNUM=0; for (( i=0 ; i<4 ; ++i )); do ((IPNUM=$IPNUM+${IP%%.*}*$((256**$((3-${i})))))); IP=${IP#*.}; done
   [ $IPNUM -gt $((2**31)) ] && IPNUM=$(($IPNUM - $((2**32))))
   LITESERVERSCONFIG="{\"id\":{\"key\":\"$LITESERVER_PUB\", \"@type\":\"pub.ed25519\"}, \"port\":\"$LITE_PORT\", \"ip\":$IPNUM, \"ws\":\"ws://$PUBLIC_IP:$WS_PORT\" }"
   echo $LITESERVERSCONFIG > liteserver.conf

   if [[ "$WS_PROXY" == 1 ]]; then
      echo "Start WS proxy on $BIND_IP:$WS_PORT"
      ws_proxy.sh &
   fi
   if [[ "$BLOCK_EXPLORER" == 1 ]]; then
      echo "Start BLOCKCHAIN explorer on $BIND_IP:$BLOCK_PORT"
      block_explorer.sh &
   fi

fi

if [[ "$GENESIS" == 1 ]]; then
cp my-ton-global.config.json initial-ton-global.config.json
fi

while [ 1 = 1 ]
do
echo "Start validator on $BIND_IP:$PUBLIC_PORT"
validator-engine -t $CORE_COUNT -C /var/ton-work/db/my-ton-global.config.json --db /var/ton-work/db --ip "$BIND_IP:$PUBLIC_PORT"  >> /var/ton-work/logs/node.log 2>&1
date -u  >> /var/ton-work/logs/node.log
echo "validator-engine exited" >> /var/ton-work/logs/node.log
date -u  >> /var/ton-work/logs/node-restarts.log
done

