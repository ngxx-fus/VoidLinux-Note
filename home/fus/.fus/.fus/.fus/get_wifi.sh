#!/bin/zsh
wifi_icon_1=(󰤯 󰤟 󰤢 󰤥 󰤨 )    #   With Internet access
wifi_icon_2=(󰤫 󰤠 󰤣 󰤦 󰤩 )    #   No Internet access 
nowifi_icon_3=󰤭             #   No Wi-Fi
RSSI_THRES=( 20 40 65 85 101)
RSSI_WARN_THRES=50

get_RSSI(){
    echo -e "$(nmcli -f IN-USE,SIGNAL dev wifi | grep '^\*' | awk '{print $2}')"
}

RSSI=$(get_RSSI)

RES=?
if [[ -z "$RSSI" ]]; then
    echo -e "$nowifi_icon_3 "
else
    echo "󰑫 $RSSI"
    return 0
    #############################################################
    for i in $( seq 1 10 ); do
        if [ $RSSI -lt ${RSSI_THRES[$i]} ]; then
            RES=${wifi_icon_1[$i]}
            break
        fi
    done
    if [ $RSSI -lt $RSSI_WARN_THRES ]; then
        echo -e "$RES"
    else
        echo -e "$RES"
    fi
fi


