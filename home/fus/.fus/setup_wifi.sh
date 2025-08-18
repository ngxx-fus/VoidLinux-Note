#!/bin/zsh 

if [ -e /home/fus/.fus/shell_utils.sh ]; then 
    source /home/fus/.fus/shell_utils.sh 
fi

# SETUP ###################################################################################

WIFI_DEV=wlo1

do_you_want_to_continue(){
    echo "Do you want to ${BOLD}${UNDERLINED}continue${NORM}? Y/N";
    while true; do 
        printf "${GRAY}Your answer:${NORM} "
        read ans 
        echo "${GRAY}Got the answer:${NORM} \"$ans\""
        case $ans in
            [Yy]*)
                echo "${LGREEN}OKE, I will continue${NORM}!"
                return 0
                ;;
            [Nn]*)
                echo "${LRED}${BOLD}I got it, cancel!${NORM}"
                return 1
                ;;
            *)
                echo "Please enter ${UNDERLINED}${BOLD}correct${NORM} form !"
        esac
    done
}

# FIRST WORDS #############################################################################
echo "$WHITE
Hi there, 
    I'm ${BOLD}ngxx.fus${NORM}${WHITE} (My name is Phu - pronounced foo)!
    
    I made this script to setup wpa_supplicant for new Wi-Fi without nmcli. I have the pr- 
oblem with nmcli, it works instable... There'are some commands that you need to control y- 
our system (Laptop) in case of lost Internet connection.

[Table 1]
    COMMAND ############################### DESCRIPTION ##################################
    sudo killall wpa_supplicant             Stops the process, the connection will be lost. 
    sudo ip link set ${WIFI_DEV} down              Turn off interface Wi-Fi. 
    sudo ip link set ${WIFI_DEV} up                Turn on interface Wi-Fi.
    iw dev ${WIFI_DEV} link                        Get information of the connection.
    sudo wpa_supplicant -B -i ${WIFI_DEV} -c /etc/wpa_supplicant/ 
                                            Start wpa_supplicant with specified properties.
    sudo iw dev ${WIFI_DEV} scan | grep SSID       List on available SSID.
    sudo wpa_passphrase "your_wifi_ssid" "your_password"
                                            Generates a secure configuration block (which 
                                            stored on /etc/wpa_supplicant/wpa_supplicant.c-
                                            onf) 

[Table 2]
    ADDRESS ############################### DESCRIPTION ##################################
    /etc/wpa_supplicant/wpa_supplicant.conf Stores Wi-Fi network names and passwords for c- 
    onnecting.
NOTE:
    In your system, may Wi-Fi interface is not \`${WIFI_DEV}\`! you should check with \`sudo iw dev\`.

Thankyou!
$NORM"


# BACK-END CHECK ##########################################################################
which iw > /dev/null 
if [ $? -eq 1 ]; then 
    echo "${LRED}ERROR: iw not found! Please install before continue!$NORM"
    exit 1 
fi

which wpa_supplicant > /dev/null 
if [ $? -eq 1 ]; then 
    echo "${LRED}ERROR: wpa_supplicant not found! Please install before continue!$NORM"
    exit 1 
fi

which wpa_passphrase > /dev/null 
if [ $? -eq 1 ]; then 
    echo "${LRED}ERROR: wpa_passphrase not found! Please install before continue!$NORM"
    exit 1 
fi

which ip > /dev/null 
if [ $? -eq 1 ]; then 
    echo "${LRED}ERROR: ip not found! Please install before continue!$NORM"
    exit 1 
fi

# GET SSID and PASSWORD ###################################################################

echo "${LYELLOW}Set ${WIFI_DEV} up...$NORM"
sudo ip link set ${WIFI_DEV} 
echo "${LGREEN}OKE!$NORM"


echo "${LYELLOW}All connections: $NORM"
sudo iw dev ${WIFI_DEV} scan \
| awk '
/BSS/ { ssid=""; enc="OPEN"; rssi=""; freq=""; width=""; rate="" }
/signal:/ { rssi=$2 " dBm" }
/freq:/ { freq=$2 " MHz" }
/width:/ { width=$2 }
/bitrate:/ && rate=="" { rate=$2 " " $3 }
/WPA/ { enc="WPA" }
/RSN/ { enc="WPA2" }
/SSID:/ { ssid=substr($0, index($0,$2)) }
/SSID:/ && ssid && rssi {
    printf "%-30s %-6s %-8s %-8s %-8s %-8s\n", ssid, enc, rssi, freq, width, rate
    ssid=""; enc="OPEN"; rssi=""; freq=""; width=""; rate=""
}
'

echo ""
NEW_SSID=
printf "${LYELLOW}Enter the SSID: $NORM" 
read NEW_SSID 
echo "${GRAY}Got SSID: \"$NEW_SSID\"$NORM"

NEW_PASSW=
printf "${LYELLOW}Enter the passcode: ${NORM}"
read NEW_PASSW
echo "${GRAY}Got PW: \"$NEW_PASSW\"$NORM"
echo ""

do_you_want_to_continue
[ $? -eq 1 ] && exit 1

echo "
${LYELLOW}Append new block$NORM
$(sudo wpa_passphrase $NEW_SSID $NEW_PASSW)
${LYELLOW}Into /etc/wpa_supplicant/wpa_supplicant.conf.$NORM 
"

do_you_want_to_continue
[ $? -eq 1 ] && exit 1 

sudo cp -vrf /etc/wpa_supplicant/wpa_supplicant.conf \
    /etc/wpa_supplicant/wpa_supplicant.conf.backup_$(date "+%d-%m-%y_%H-%M-%S")
sudo echo "

# ${NEW_SSID} 
$(sudo wpa_passphrase $NEW_SSID $NEW_PASSW)
" | sudo tee -a /etc/wpa_supplicant/wpa_supplicant.conf

echo "${LYELLOW}DONE!$NORM

${LYELLOW}/etc/wpa_supplicant/wpa_supplicant.conf${NORM}:
$(sudo cat /etc/wpa_supplicant/wpa_supplicant.conf)
"

echo "$LYELLOW
Restart wpa_supplicant. (You need to restart system to see the result)
$NORM"

kill $(pgrep wpa_supplicant)
sudo wpa_supplicant -B -i ${WIFI_DEV} -c /etc/wpa_supplicant/wpa_supplicant.conf 
# sudo dhclient ${WIFI_DEV}

echo "${LGREEN}OKE!$NORM"
