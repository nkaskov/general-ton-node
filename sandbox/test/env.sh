export REPO_PATH=../..

export IMAGE_NAME="ton-rocks-image"
export DOCKER_NAME="ton-rocks-nodet0"
export VOLUME_NAME="ton-rocks-dbt0"

export CONFIG="http://127.0.0.1:8080/my-ton-global.config.json"

export PUBLIC_IP=127.0.0.1
#export PUBLIC_IP=$(curl -sS 2ip.ru)
export BIND_IP=0.0.0.0

export DHT_PORT=20303
export ADNL_PORT=20310
export CONSOLE_PORT=20000
export LITE_PORT=26732
export JSON_EXPLORER_PORT=2082
export BLOCK_EXPLORER_PORT=2083

# only for genesis
export GENESIS=0
export HTTP_PORT=
#export CONFIG="http://127.0.0.1:${HTTP_PORT}/my-ton-global.config.json"
export SANDBOX=

