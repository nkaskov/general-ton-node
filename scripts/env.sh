export REPO_PATH=..

export IMAGE_NAME="ton-rocks-image"
export DOCKER_NAME="ton-rocks-node"
export VOLUME_NAME="ton-rocks-db"

export CONFIG="https://raw.githubusercontent.com/ton-rocks/network-config/master/test.rocks.config.json"

#export PUBLIC_IP=127.0.0.1
export PUBLIC_IP=$(curl -sS 2ip.ru)
export BIND_IP=0.0.0.0

export DHT_PORT=30303
export ADNL_PORT=30310
export CONSOLE_PORT=50000
export LITE_PORT=46732
export JSON_EXPLORER_PORT=8082
export BLOCK_EXPLORER_PORT=8083

# only for genesis
export GENESIS=0
export HTTP_PORT=
#export CONFIG="http://127.0.0.1:${HTTP_PORT}/my-ton-global.config.json"
export SANDBOX=

