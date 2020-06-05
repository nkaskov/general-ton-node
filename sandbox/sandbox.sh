DOCKER_IMAGE="user/general-ton-node:0.1.0"
LITE_PORT=46732
HTTPPORT=8081

docker volume create ton-db0
docker run -d --name ton-node-n0 --mount source=ton-db0,target=/var/ton-work/db --network host \
-e "GENESIS=1" -e "SERVECONFIG=1" -e "HTTPPORT=${HTTPPORT}" -e "DHT_SERVER=1" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30310" -e "DHT_PORT=30303" -e "CONSOLE_PORT=50000" -e "LITESERVER=true" -e "LITE_PORT=${LITE_PORT}" \
-it $DOCKER_IMAGE

docker logs --follow ton-node-n0 >> logs-node0.txt &

sleep 60

docker cp ton-node-n0:/var/ton-work/db/my-ton-global.config.json .
docker cp ton-node-n0:/var/ton-work/contracts/main-wallet.addr .
docker cp ton-node-n0:/var/ton-work/contracts/main-wallet.pk .

docker volume create ton-db1
docker run -d --name ton-node-n1 --mount source=ton-db1,target=/var/ton-work/db --network host \
-e"CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json"  -e "DHT_SERVER=1" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30311" -e "DHT_PORT=30304" -e "CONSOLE_PORT=50001" -it $DOCKER_IMAGE
docker logs --follow ton-node-n1 >> logs-node1.txt &
sleep 60
docker cp ton-node-n1:/var/ton-work/db/dht_node.conf ./dht_node1.conf

docker volume create ton-db2
docker run -d --name ton-node-n2 --mount source=ton-db2,target=/var/ton-work/db --network host \
-e "CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json"  -e "DHT_SERVER=1" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30312" -e "DHT_PORT=30305" -e "CONSOLE_PORT=50002" -it $DOCKER_IMAGE
docker logs --follow ton-node-n2 >> logs-node2.txt &
sleep 60
docker cp ton-node-n2:/var/ton-work/db/dht_node.conf ./dht_node2.conf

docker volume create ton-db3
docker run -d --name ton-node-n3 --mount source=ton-db3,target=/var/ton-work/db --network host \
-e "CONFIG=http://127.0.0.1:${HTTPPORT}/my-ton-global.config.json"  -e "DHT_SERVER=0" -e "PUBLIC_IP=127.0.0.1" -e "BIND_IP=0.0.0.0" \
-e "PUBLIC_PORT=30313" -e "DHT_PORT=30306" -e "CONSOLE_PORT=50003" -it $DOCKER_IMAGE
docker logs --follow ton-node-n3 >> logs-node3.txt &


sleep 60

echo "====================== Node0 stats"
docker exec -it ton-node-n0 validator-engine-console -a 127.0.0.1:50000 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node1 stats"
docker exec -it ton-node-n1 validator-engine-console -a 127.0.0.1:50001 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node2 stats"
docker exec -it ton-node-n2 validator-engine-console -a 127.0.0.1:50002 -k client -p server.pub -c "getstats" -c "quit"
echo "====================== Node3 stats"
docker exec -it ton-node-n3 validator-engine-console -a 127.0.0.1:50003 -k client -p server.pub -c "getstats" -c "quit"

echo "====================== Lite client cmd"
docker exec -it ton-node-n3 lite-client -C my-ton-global.config.json
# getaccount -1:0000000000000000000000000000000000000000000000000000000000000000
# quit

sudo iftop -i lo -P

# cleanup

docker stop ton-node-n0
docker rm ton-node-n0
docker volume rm ton-db0

docker stop ton-node-n1
docker rm ton-node-n1
docker volume rm ton-db1

docker stop ton-node-n2
docker rm ton-node-n2
docker volume rm ton-db2

docker stop ton-node-n3
docker rm ton-node-n3
docker volume rm ton-db3

