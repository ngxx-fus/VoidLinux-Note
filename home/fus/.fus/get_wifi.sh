#!/bin/zsh

wifi_icon_1=(󰤯 󰤟 󰤢 󰤥 󰤨 )    #   With Internet access
wifi_icon_2=(󰤫 󰤠 󰤣 󰤦 󰤩 )    #   No Internet access 
nowifi_icon_3=󰤭             #   No Wi-Fi
THRES_1=85                  #   RSSI: very good
THRES_2=65                  #   RSSI: good
THRES_3=40                  #   RSSI: not bad
THRES_4=20                  #   RSSI: bad
# INTERNET_CHECK_RESULT_PATH=/tmp/.data_exchange/internet_check

get_RSSI(){
    echo "$(nmcli -f IN-USE,SIGNAL dev wifi | grep '^\*' | awk '{print $2}')"
}

RSSI=$(get_RSSI)
HAS_INTERNET=0
# if [ -e $INTERNET_CHECK_RESULT_PATH ]; then
    # HAS_INTERNET=$(cat $INTERNET_CHECK_RESULT_PATH)
# fi

RES=

if [[ -z "$RSSI" ]]; then
    echo "$nowifi_icon_3"
    return 1;
else
    if [  $HAS_INTERNET -eq 0 ]; then
        if [ $RSSI -lt $THRES_4 ]; then
            echo "${wifi_icon_1[1]}"
        else 
            if [ $RSSI -lt $THRES_3 ]; then 
                echo "${wifi_icon_1[2]}"
            else
                if [ $RSSI -lt $THRES_2 ]; then
                    echo "${wifi_icon_1[3]}"
                else
                    if [ $RSSI -lt $THRES_1 ]; then
                        echo "${wifi_icon_1[4]}"
                    else
                        echo "${wifi_icon_1[5]}"
                    fi
                fi
            fi
        fi
    else
        if [ $RSSI -lt $THRES_4 ]; then
            echo "${wifi_icon_2[1]}"
        else 
            if [ $RSSI -lt $THRES_3 ]; then 
                echo "${wifi_icon_2[2]}"
            else
                if [ $RSSI -lt $THRES_2 ]; then
                    echo "${wifi_icon_2[3]}"
                else
                    if [ $RSSI -lt $THRES_1 ]; then
                        echo "${wifi_icon_2[4]}"
                    else
                        echo "${wifi_icon_2[5]}"
                    fi
                fi
            fi
        fi
    fi
fi

