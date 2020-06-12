export REPO_PATH=../..

export IMAGE_NAME="ton-rocks-image"
export DOCKER_NAME="ton-rocks-nodes0"
export VOLUME_NAME="ton-rocks-dbs0"

export PUBLIC_IP=127.0.0.1
#export PUBLIC_IP=$(curl -sS 2ip.ru)
export BIND_IP=0.0.0.0

export DHT_PORT=30303
export ADNL_PORT=30310
export CONSOLE_PORT=50000
export LITE_PORT=46732
export JSON_EXPLORER_PORT=8082
export BLOCK_EXPLORER_PORT=8083

# only for genesis
export GENESIS=1
export HTTP_PORT=8080
#export CONFIG="http://127.0.0.1:${HTTP_PORT}/my-ton-global.config.json"
export SANDBOX=1

