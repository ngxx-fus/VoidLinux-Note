#!/bin/zsh
wifi_icon_1=(󰤯 󰤟 󰤢 󰤥 󰤨 )    #   With Internet access
wifi_icon_2=(󰤫 󰤠 󰤣 󰤦 󰤩 )    #   No Internet access 
nowifi_icon_3=󰤭             #   No Wi-Fi
RSSI_THRES=( 20 40 65 85 101)
RSSI_WARN_THRES=50

get_RSSI(){
    # echo -e "$(nmcli -f IN-USE,SIGNAL dev wifi | grep '^\*' | awk '{print $2}')"
    echo -e "$(iw dev wlo1 link | awk '/signal/ {print $2}')"
}

RSSI=$(get_RSSI)

EHTERNET=
ip a | grep enp > /dev/null
if [ $? -eq 0 ]; then
    EHTERNET=" |  "
fi

RES=?
if [[ -z "$RSSI" ]]; then
    echo -e "$nowifi_icon_3 $EHTERNET"
else
    echo "󰑫 $RSSI$EHTERNET"
    return 0
fi


