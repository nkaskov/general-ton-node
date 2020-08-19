

if [ -z "$1" ]; then
    echo "Specify filebase"
    exit
fi

BASE=$1

if test -f "$BASE-deploy-query.boc"; then
    lite-client -C /var/ton-work/db/my-ton-global.config.json -v 0 -c "sendfile ${BASE}-deploy-query.boc"
    echo "Done"
else
    echo "Cannot find query for wallet"
fi
