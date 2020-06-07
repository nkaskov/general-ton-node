DOCKER_IMAGE="user/general-ton-node:0.1.0"
LITE_PORT=46732
HTTPPORT=8081

docker volume create ton-db0
docker run -d --name ton-node-n0 --mount source=ton-db0,target=/var/ton-work/db --network host \
-e "GENESIS=1" -e "SERVECONFIG=1" -e "HTTPPORT=${HTTPPORT}" -e "DHT_SERVER=1" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30310" -e "DHT_PORT=30303" -e "CONSOLE_PORT=50000" -e "LITESERVER=true" -e "LITE_PORT=${LITE_PORT}" \
-it $DOCKER_IMAGE

docker logs --follow ton-node-n0 >> logs-node0.txt &

sleep 100

docker cp ton-node-n0:/var/ton-work/db/my-ton-global.config.json .
docker cp ton-node-n0:/var/ton-work/db/dht_validator.conf .
docker cp ton-node-n0:/var/ton-work/contracts/main-wallet.addr .
docker cp ton-node-n0:/var/ton-work/contracts/main-wallet.pk .


docker volume create ton-db1
docker run -d --name ton-node-n1 --mount source=ton-db1,target=/var/ton-work/db --network host \
-e "CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json" -e "DHT_SERVER=0" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30311" -e "DHT_PORT=30304" -e "CONSOLE_PORT=50001" -it $DOCKER_IMAGE
docker logs --follow ton-node-n1 >> logs-node1.txt &
sleep 60
docker cp ton-node-n1:/var/ton-work/db/dht_node.conf ./dht_node1.conf
docker cp ton-node-n1:/var/ton-work/db/dht_validator.conf ./dht_validator1.conf

docker volume create ton-db2
docker run -d --name ton-node-n2 --mount source=ton-db2,target=/var/ton-work/db --network host \
-e "CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json" -e "DHT_SERVER=0" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30312" -e "DHT_PORT=30305" -e "CONSOLE_PORT=50002" -it $DOCKER_IMAGE
docker logs --follow ton-node-n2 >> logs-node2.txt &
sleep 60
docker cp ton-node-n2:/var/ton-work/db/dht_node.conf ./dht_node2.conf
docker cp ton-node-n2:/var/ton-work/db/dht_validator.conf ./dht_validator2.conf

docker volume create ton-db3
docker run -d --name ton-node-n3 --mount source=ton-db3,target=/var/ton-work/db --network host \
-e "CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json" -e "DHT_SERVER=0" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30313" -e "DHT_PORT=30306" -e "CONSOLE_PORT=50003" -it $DOCKER_IMAGE
docker logs --follow ton-node-n3 >> logs-node3.txt &
sleep 60
docker cp ton-node-n3:/var/ton-work/db/dht_node.conf ./dht_node3.conf
docker cp ton-node-n3:/var/ton-work/db/dht_validator.conf ./dht_validator3.conf

echo "====================== Node0 stats"
docker exec -it ton-node-n0 validator-engine-console -a 127.0.0.1:50000 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node1 stats"
docker exec -it ton-node-n1 validator-engine-console -a 127.0.0.1:50001 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node2 stats"
docker exec -it ton-node-n2 validator-engine-console -a 127.0.0.1:50002 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node3 stats"
docker exec -it ton-node-n3 validator-engine-console -a 127.0.0.1:50003 -k client -p server.pub -c "getstats" -c "quit"


# wallets creation
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_create.sh validator"
docker cp ton-node-n0:/var/ton-work/contracts/validator.hexaddr ./validator0.hexaddr
docker cp ton-node-n0:/var/ton-work/contracts/validator.pk ./validator0.pk
V0_ADDR=$(cat validator0.hexaddr)

docker exec -it ton-node-n1 bash -c "cd /var/ton-work/contracts && wallet_create.sh validator"
docker cp ton-node-n1:/var/ton-work/contracts/validator.hexaddr ./validator1.hexaddr
docker cp ton-node-n1:/var/ton-work/contracts/validator.pk ./validator1.pk
V1_ADDR=$(cat validator1.hexaddr)

docker exec -it ton-node-n2 bash -c "cd /var/ton-work/contracts && wallet_create.sh validator"
docker cp ton-node-n2:/var/ton-work/contracts/validator.hexaddr ./validator2.hexaddr
docker cp ton-node-n2:/var/ton-work/contracts/validator.pk ./validator2.pk
V2_ADDR=$(cat validator2.hexaddr)

docker exec -it ton-node-n3 bash -c "cd /var/ton-work/contracts && wallet_create.sh validator"
docker cp ton-node-n3:/var/ton-work/contracts/validator.hexaddr ./validator3.hexaddr
docker cp ton-node-n3:/var/ton-work/contracts/validator.pk ./validator3.pk
V3_ADDR=$(cat validator3.hexaddr)

# transfer 
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V0_ADDR 40000"
sleep 10
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V1_ADDR 40000"
sleep 10
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V2_ADDR 40000"
sleep 10
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V3_ADDR 40000"
sleep 10

# check
docker exec -it ton-node-n0 bash -c "wallet_status.sh $V0_ADDR"
docker exec -it ton-node-n1 bash -c "wallet_status.sh $V1_ADDR"
docker exec -it ton-node-n2 bash -c "wallet_status.sh $V2_ADDR"
docker exec -it ton-node-n3 bash -c "wallet_status.sh $V3_ADDR"

# deploy
docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && wallet_deploy.sh validator"
docker exec -it ton-node-n1 bash -c "cd /var/ton-work/contracts && wallet_deploy.sh validator"
docker exec -it ton-node-n2 bash -c "cd /var/ton-work/contracts && wallet_deploy.sh validator"
docker exec -it ton-node-n3 bash -c "cd /var/ton-work/contracts && wallet_deploy.sh validator"

sleep 30

# check
docker exec -it ton-node-n0 bash -c "wallet_status.sh $V0_ADDR"
docker exec -it ton-node-n1 bash -c "wallet_status.sh $V1_ADDR"
docker exec -it ton-node-n2 bash -c "wallet_status.sh $V2_ADDR"
docker exec -it ton-node-n3 bash -c "wallet_status.sh $V3_ADDR"
docker exec -it ton-node-n3 bash -c "wallet_status.sh -1:3333333333333333333333333333333333333333333333333333333333333333"
docker exec -it ton-node-n3 bash -c "wallet_status.sh -1:0000000000000000000000000000000000000000000000000000000000000000"

echo "====================== Start election registration"

reap() {
    docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
    docker exec -it ton-node-n1 bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
    docker exec -it ton-node-n2 bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
    docker exec -it ton-node-n3 bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
}

participate() {
    docker exec -it ton-node-n0 bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"
    docker exec -it ton-node-n1 bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"
    docker exec -it ton-node-n2 bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"
    docker exec -it ton-node-n3 bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"
}

get_logs() {
    docker cp ton-node-n0:/var/ton-work/logs/participate.txt ./participate0.log.txt
    docker cp ton-node-n0:/var/ton-work/logs/reap.txt ./reap0.log.txt
    docker cp ton-node-n1:/var/ton-work/logs/participate.txt ./participate1.log.txt
    docker cp ton-node-n1:/var/ton-work/logs/reap.txt ./reap1.log.txt
    docker cp ton-node-n2:/var/ton-work/logs/participate.txt ./participate2.log.txt
    docker cp ton-node-n2:/var/ton-work/logs/reap.txt ./reap2.log.txt
    docker cp ton-node-n3:/var/ton-work/logs/participate.txt ./participate3.log.txt
    docker cp ton-node-n3:/var/ton-work/logs/reap.txt ./reap3.log.txt
}

echo "====================== Election params: "
docker exec -it ton-node-n0 lite-client -C my-ton-global.config.json -v 0 -rc "getconfig 15" -rc "quit"


while true; do

    reap
    participate

    echo "Sleep 60. Press CTRL-C for exit"
    sleep 60

    get_logs
    
    echo "====================== WALLETS" 
    docker exec -it ton-node-n0 bash -c "wallet_status.sh $V0_ADDR"
    docker exec -it ton-node-n1 bash -c "wallet_status.sh $V1_ADDR"
    docker exec -it ton-node-n2 bash -c "wallet_status.sh $V2_ADDR"
    docker exec -it ton-node-n3 bash -c "wallet_status.sh $V3_ADDR"
    docker exec -it ton-node-n3 bash -c "wallet_status.sh -1:3333333333333333333333333333333333333333333333333333333333333333"

    echo "====================== UTC time" 
    date -u +%s

    echo "====================== Active election id: "
    docker exec -it ton-node-n0 lite-client -C my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 active_election_id" -rc "quit" | grep "result: "

    echo "====================== Current validators: "
    docker exec -it ton-node-n0 lite-client -C my-ton-global.config.json -v 0 -rc "getconfig 34" -rc "quit"

    echo "====================== Election participant list: "
    docker exec -it ton-node-n0 lite-client -C my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 participant_list" -rc "quit" | grep "result: "

done

#echo "====================== Lite client cmd"
#docker exec -it ton-node-n3 lite-client -v 0 -C my-ton-global.config.json
# getaccount -1:0000000000000000000000000000000000000000000000000000000000000000
# quit

#sudo iftop -i lo -P
