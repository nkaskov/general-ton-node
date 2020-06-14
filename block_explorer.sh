
#!/usr/bin/env bash

while [ 1 = 1 ]
do
blockchain-explorer -l /var/ton-work/logs/blockchain-explorer.log -H $BLOCK_PORT -p /var/ton-work/db/liteserver.pub -a "127.0.0.1:$LITE_PORT"
date -u  >> /var/ton-work/logs/blockchain-explorer.log
echo "blockchain-explorer exited" >> /var/ton-work/logs/blockchain-explorer.log
done
