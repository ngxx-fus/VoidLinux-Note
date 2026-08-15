#!/bin/zsh

 #
 # @file status_network.zsh
 # @brief Network status monitor script for Zsh / status bar on Void Linux.
 # @details Retrieves RSSI from wlan0, maps signal quality to Nerd Font icons,
 #          checks Internet reachability, and detects active Ethernet links.
 #

wifi_icon_1=(󰤯 󰤟 󰤢 󰤥 󰤨)    # With Internet access (Levels 1 -> 5)
wifi_icon_2=(󰤫 󰤠 󰤣 󰤦 󰤩)    # No Internet access (Levels 1 -> 5)
nowifi_icon_3="󰤭"             # No Wi-Fi
default_wifi_icon="󰑫"         # Fallback Wi-Fi icon

RSSI_THRES=(20 40 65 85 101)
DEVICENAME_ETH="eth0"
DEVICENAME_WIFI="wlan0"
CONFIG_WIFI_CHANGE_ICON_EN=1
CONFIG_WIFI_SHOW_RSSI_EN=0

 #
 # @brief Retrieve numerical RSSI value in dBm from wireless interface.
 # @return None. Outputs RSSI string via stdout.
 #
get_RSSI() {
    # Extract numerical RSSI from iw link output
    echo "$(iw dev "$DEVICENAME_WIFI" link 2>/dev/null | awk '/signal/ {print $2}')"
}

 #
 # @brief Verify Internet connectivity via ICMP echo.
 # @return 0 on success, 1 on timeout/unreachable.
 #
has_internet() {
    # Control flow: Check if ping packet receives an echo reply
    if ping -c 1 -W 1 1.1.1.1 >/dev/null 2>&1; then
        # Return success when host is reachable
        return 0
    fi
    # Return failure when host is unreachable
    return 1
}

RSSI=$(get_RSSI)

SPACE=""
ETHERNET=""

# Control flow: Detect if Ethernet interface is present and in UP state
if ip link show "$DEVICENAME_ETH" 2>/dev/null | grep -q "state UP"; then
    ETHERNET="|  "
    SPACE=" "
fi

# Steering logic: Handle disconnected Wi-Fi state vs active link
if [[ -z "$RSSI" ]]; then
    # Output no-wifi icon with optional Ethernet indicator
    echo -e "${nowifi_icon_3}${SPACE}${ETHERNET}"
    # Terminate script execution on disconnection
    return 0 2>/dev/null || exit 0
fi

# Steering logic: Check if dynamic icon evaluation is enabled
if (( CONFIG_WIFI_CHANGE_ICON_EN == 1 )); then
    # Convert RSSI (dBm) to percentage range (0% to 100%)
    RSSI_VAL=${RSSI%.*}
    RSSI_VAL=${RSSI_VAL#-}
    RSSI_NUM=$(( -1 * RSSI_VAL ))

    # Control flow: Clamp and scale signal quality percentage
    if (( RSSI_NUM >= -50 )); then
        QUALITY=100
    elif (( RSSI_NUM <= -100 )); then
        QUALITY=0
    else
        QUALITY=$(( 2 * (RSSI_NUM + 100) ))
    fi

    ICON_IDX=1
    # Steering logic: Map signal quality percentage to threshold bracket
    for idx in {1..5}; do
        # Control flow: Check if quality falls within current threshold bucket
        if (( QUALITY <= RSSI_THRES[idx] )); then
            ICON_IDX=$idx
            # Break loop when matching bracket is identified
            break
        fi
    done

    # Steering logic: Select icon set based on Internet reachability
    if has_internet; then
        CHOSEN_ICON="${wifi_icon_1[ICON_IDX]}"
    else
        CHOSEN_ICON="${wifi_icon_2[ICON_IDX]}"
    fi
else
    # Assign default static icon when dynamic feature is disabled
    CHOSEN_ICON="$default_wifi_icon"
fi

OUTPUT_TEXT="${CHOSEN_ICON} "

# Steering logic: Append RSSI string if configured to show
if (( CONFIG_WIFI_SHOW_RSSI_EN == 1 )); then
    OUTPUT_TEXT="${OUTPUT_TEXT} ${RSSI}"
fi

# Output formatted status string with optional Ethernet info
echo -e "${OUTPUT_TEXT}${SPACE}${ETHERNET}"

# Terminate script execution successfully
return 0 2>/dev/null || exit 0
