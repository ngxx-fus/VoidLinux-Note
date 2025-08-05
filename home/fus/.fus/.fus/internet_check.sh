#!/bin/zsh

DATA_EXCHANGE_PATH=/tmp/.data_exchange
OUTPUT_FILENAME=internet_check
SLEEP_TIME=1
PING_COUNT=4
CHECK_IP=8.8.8.8

get_RSSI(){
    echo "$(nmcli -f IN-USE,SIGNAL dev wifi | grep '^\*' | awk '{print $2}')"
}

internet_check(){
    if ping -c $PING_COUNT $CHECK_IP > /dev/null; then
        return 0;
    else
        return -1;
    fi
}

mkdir -p $DATA_EXCHANGE_PATH
touch $DATA_EXCHANGE_PATH/$OUTPUT_FILENAME

while true; do
    if [[ -z "$(get_RSSI)" ]]; then
        echo "1" > $DATA_EXCHANGE_PATH/$OUTPUT_FILENAME
    else 
        internet_check
        echo "$?" > $DATA_EXCHANGE_PATH/$OUTPUT_FILENAME
    fi

    sleep $SLEEP_TIME

done
