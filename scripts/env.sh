export REPO_PATH=..

export IMAGE_NAME="ton-rocks-image"
export DOCKER_NAME="ton-rocks-node"

export VOLUME_NAME="ton-rocks-db"
# or
#export TON_DIR="/var/ton-work"

export CONFIG="https://raw.githubusercontent.com/Battlelore21/network-config/master/testnet2.config.json"
export TON_REPO="https://github.com/Battlelore21/ton.git"
export TON_COMMIT="88f1c40834069e717855c3b3e3b7cb5265655f71"

export CORE_COUNT=$((`grep processor /proc/cpuinfo | wc -l` * 1))

#export PUBLIC_IP=127.0.0.1
export PUBLIC_IP=$(curl -sS 2ip.ru)
export BIND_IP=0.0.0.0

#export DHT_PORT=30303
export ADNL_PORT=30310
export CONSOLE_PORT=50000
export LITE_PORT=46732
export WS_PORT=46733
export BLOCK_EXPLORER_PORT=8083

# only for genesis
export GENESIS=0
export HTTP_PORT=
#export CONFIG="http://127.0.0.1:${HTTP_PORT}/my-ton-global.config.json"
export SANDBOX=

