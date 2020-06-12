SC=../../scripts

cd node0
$SC/docker_create_storage.sh
$SC/docker_run.sh
source ./env.sh && echo > live-node.txt && docker logs --follow $DOCKER_NAME >> live-node.txt &
sleep 100
$SC/docker_export_wallet.sh y
$SC/docker_export_conf.sh
$SC/docker_logs.sh
cd ..


cd node1
$SC/docker_create_storage.sh
$SC/docker_run.sh
source ./env.sh && echo > live-node.txt && docker logs --follow $DOCKER_NAME >> live-node.txt &
sleep 20
$SC/docker_export_wallet.sh y
$SC/docker_export_conf.sh
$SC/docker_logs.sh
cd ..

cd node2
$SC/docker_create_storage.sh
$SC/docker_run.sh
source ./env.sh && echo > live-node.txt && docker logs --follow $DOCKER_NAME >> live-node.txt &
sleep 20
$SC/docker_export_wallet.sh y
$SC/docker_export_conf.sh
$SC/docker_logs.sh
cd ..

cd node3
$SC/docker_create_storage.sh
$SC/docker_run.sh
source ./env.sh && echo > live-node.txt && docker logs --follow $DOCKER_NAME >> live-node.txt &
sleep 20
$SC/docker_export_wallet.sh y
$SC/docker_export_conf.sh
$SC/docker_logs.sh
cd ..

sleep 30

# check nodes status
cd node0
$SC/docker_status.sh
$SC/docker_wallet_status.sh
cd ..
cd node1
$SC/docker_status.sh
$SC/docker_wallet_status.sh
cd ..
cd node2
$SC/docker_status.sh
$SC/docker_wallet_status.sh
cd ..
cd node3
$SC/docker_status.sh
$SC/docker_wallet_status.sh
cd ..

V0_ADDR=$(cat node0/validator.hexaddr)
V1_ADDR=$(cat node1/validator.hexaddr)
V2_ADDR=$(cat node2/validator.hexaddr)
V3_ADDR=$(cat node3/validator.hexaddr)

cd node0
# transfer
source ./env.sh && docker exec -it $DOCKER_NAME bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V0_ADDR 100000"
sleep 10
source ./env.sh && docker exec -it $DOCKER_NAME bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V1_ADDR 100000"
sleep 10
source ./env.sh && docker exec -it $DOCKER_NAME bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V2_ADDR 100000"
sleep 10
source ./env.sh && docker exec -it $DOCKER_NAME bash -c "cd /var/ton-work/contracts && wallet_main_transfer.sh $V3_ADDR 100000"
sleep 10
cd ..

cd node0
$SC/docker_wallet_status.sh
$SC/docker_wallet_deploy.sh
sleep 10
$SC/docker_wallet_status.sh
cd ..
cd node1
$SC/docker_wallet_status.sh
$SC/docker_wallet_deploy.sh
sleep 10
$SC/docker_wallet_status.sh
cd ..
cd node2
$SC/docker_wallet_status.sh
$SC/docker_wallet_deploy.sh
sleep 10
$SC/docker_wallet_status.sh
cd ..
cd node3
$SC/docker_wallet_status.sh
$SC/docker_wallet_deploy.sh
sleep 10
$SC/docker_wallet_status.sh
source ./env.sh && docker exec -it  $DOCKER_NAME bash -c "wallet_status.sh -1:3333333333333333333333333333333333333333333333333333333333333333"
source ./env.sh && docker exec -it  $DOCKER_NAME bash -c "wallet_status.sh -1:0000000000000000000000000000000000000000000000000000000000000000"
cd ..

sleep 100

reap() {
    source ./env.sh && docker exec -it  $DOCKER_NAME bash -c "cd /var/ton-work/contracts && reap.sh >> /var/ton-work/logs/reap.txt 2>&1"
}

participate() {
    source ./env.sh && docker exec -it  $DOCKER_NAME bash -c "cd /var/ton-work/contracts && participate.sh >> /var/ton-work/logs/participate.txt 2>&1"
}

get_logs() {
    source ./env.sh && docker cp $DOCKER_NAME:/var/ton-work/logs/json-explorer.log .
    source ./env.sh && docker cp $DOCKER_NAME:/var/ton-work/logs/blockchain-explorer.log .
    source ./env.sh && docker cp $DOCKER_NAME:/var/ton-work/logs/participate.txt ./participate.log
    source ./env.sh && docker cp $DOCKER_NAME:/var/ton-work/logs/reap.txt ./reap.log
}

cd node0
echo "====================== Election params: "
source ./env.sh && docker exec -it $DOCKER_NAME lite-client -C my-ton-global.config.json -v 0 -rc "getconfig 15"  -rc "getconfig 16" -rc "getconfig 17" -rc "quit"
cd ..

while true; do

cd node0
reap
participate
cd ..
cd node1
reap
participate
cd ..
cd node2
reap
participate
cd ..
cd node3
reap
participate
cd ..

echo "Sleep 60. Press CTRL-C for exit"
sleep 60

echo "====================== WALLETS"
cd node0
get_logs
$SC/docker_wallet_status.sh
cd ..
cd node1
get_logs
$SC/docker_wallet_status.sh
cd ..
cd node2
get_logs
$SC/docker_wallet_status.sh
cd ..
cd node3
get_logs
$SC/docker_wallet_status.sh
source ./env.sh && docker exec -it  $DOCKER_NAME bash -c "wallet_status.sh -1:3333333333333333333333333333333333333333333333333333333333333333"


echo "====================== UTC time"
date -u +%s

echo "====================== Active election id: "
source ./env.sh && docker exec -it $DOCKER_NAME lite-client -C my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 active_election_id" -rc "quit" | grep "result: "

echo "====================== Current validators: "
source ./env.sh && docker exec -it $DOCKER_NAME lite-client -C my-ton-global.config.json -v 0 -rc "getconfig 34" -rc "quit"

echo "====================== Election participant list: "
source ./env.sh && docker exec -it $DOCKER_NAME lite-client -C my-ton-global.config.json -v 0 -rc "runmethod -1:3333333333333333333333333333333333333333333333333333333333333333 participant_list" -rc "quit" | grep "result: "
cd ..

done

#echo "====================== Lite client cmd"
# source ./env.sh && docker exec -it $DOCKER_NAME lite-client -v 0 -C my-ton-global.config.json
# getaccount -1:0000000000000000000000000000000000000000000000000000000000000000
# quit

#sudo iftop -i lo -P

