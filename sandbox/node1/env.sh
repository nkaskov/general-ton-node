export REPO_PATH=../..

export IMAGE_NAME="ton-rocks-image"
export DOCKER_NAME="ton-rocks-nodes1"
export VOLUME_NAME="ton-rocks-dbs1"

export PUBLIC_IP=127.0.0.1
#export PUBLIC_IP=$(curl -sS 2ip.ru)
export BIND_IP=0.0.0.0

export DHT_PORT=30304
export ADNL_PORT=30311
export CONSOLE_PORT=50001
export LITE_PORT=46733
export JSON_EXPLORER_PORT=8182
export BLOCK_EXPLORER_PORT=8183

# only for genesis
export GENESIS=0
export HTTP_PORT=
export CONFIG="http://127.0.0.1:8080/my-ton-global.config.json"
export SANDBOX=

