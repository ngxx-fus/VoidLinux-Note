#!/bin/zsh
wifi_icon_1=(󰤯 󰤟 󰤢 󰤥 󰤨 )    #   With Internet access
wifi_icon_2=(󰤫 󰤠 󰤣 󰤦 󰤩 )    #   No Internet access 
nowifi_icon_3=󰤭             #   No Wi-Fi
RSSI_THRES=( 20 40 65 85 101)
RSSI_WARN_THRES=50

get_RSSI(){
    echo -e "$(iw dev wlo1 link | awk '/signal/ {print $2}')"
}

RSSI=$(get_RSSI)

SPACE=
EHTERNET=
ip a | grep enp > /dev/null
if [ $? -eq 0 ]; then
    EHTERNET="|  "
    SPACE=" "
fi

RES=?
if [[ -z "$RSSI" ]]; then
    echo -e "$EHTERNET"
    # echo -e "| $nowifi_icon_3 $EHTERNET"
else
    echo "| 󰑫 $RSSI$SPACE$EHTERNET"
    return 0
fi


