#This is free and unencumbered software released into the public domain.

#Anyone is free to copy, modify, publish, use, compile, sell, or
#distribute this software, either in source code form or as a compiled
#binary, for any purpose, commercial or non-commercial, and by any
#means.

#In jurisdictions that recognize copyright laws, the author or authors
#of this software dedicate any and all copyright interest in the
#software to the public domain. We make this dedication for the benefit
#of the public at large and to the detriment of our heirs and
#successors. We intend this dedication to be an overt act of
#relinquishment in perpetuity of all present and future rights to this
#software under copyright law.

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
#OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
#ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.

#For more information, please refer to <https://unlicense.org>
# (c) Mercuryo and Viacheslav Akhmetov

echo "Reap started"
date -u
date -u +%s

LITECLIENT="lite-client"
LITECLIENT_CONFIG="/var/ton-work/db/my-ton-global.config.json"
LITECLIENT_EXTRA="-t 30 -p /var/ton-work/db/liteserver.pub -a 127.0.0.1:${LITE_PORT}"
FIFTBIN="fift"
export FIFTPATH="/usr/local/lib/fift/"
WALLET_FIF=$CONTRACTS_PATH"wallet.fif"
WALLETKEYS_DIR="/var/ton-work/contracts/"
VALIDATOR_WALLET_FILEBASE="validator"
WALLET_ADDR=$(cat $WALLETKEYS_DIR$VALIDATOR_WALLET_FILEBASE.hexaddr)

ACTIVE_ELECTION_ID=$(${LITECLIENT} ${LITECLIENT_EXTRA} -v 0 -c "getconfig 1" |grep x{|sed -e 's/{/\ /g' -e 's/}//g'|awk {'print $2'})

${LITECLIENT} ${LITECLIENT_EXTRA} -v 0 -rc "runmethod Ef8zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0vF compute_returned_stake 0x$(echo "${WALLET_ADDR}" | cut -d ':' -f 2)" -rc "quit" >"recover-state"
awk '{
        if ($1 == "result:") {
            print $3
        }
    }' "recover-state" >"recover-amount"

RETURNED_STAKE=$(cat "recover-amount")
echo "Returned stake ${RETURNED_STAKE}"
if [ "$RETURNED_STAKE" == "0" ]; then
    echo "Nothing to return"
    exit
fi

WALLET_SEQ=$(${LITECLIENT} ${LITECLIENT_EXTRA} -v 0 -c "getaccount ${WALLET_ADDR}" |grep 'x{'| tail -n1|cut -c 4-|cut -c -8)

echo "${FIFTBIN} -s ${WALLET_FIF} $WALLETKEYS_DIR$VALIDATOR_WALLET_FILEBASE -1:${ACTIVE_ELECTION_ID} 0x${WALLET_SEQ} 1. -B recover-query.boc"

#${FIFTBIN} -s ${WALLET_FIF} $WALLETKEYS_DIR$VALIDATOR_WALLET_FILEBASE -1:${ACTIVE_ELECTION_ID} 0x${WALLET_SEQ} 1. -B recover-query.boc
#Ef8zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0vF
${FIFTBIN} -s $CONTRACTS_PATH"recover-stake.fif"
${FIFTBIN} -s ${WALLET_FIF} $WALLETKEYS_DIR$VALIDATOR_WALLET_FILEBASE Ef8zMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzMzM0vF 0x${WALLET_SEQ} 1. -B recover-query.boc


${LITECLIENT} ${LITECLIENT_EXTRA} -v 0 -c "sendfile wallet-query.boc"
