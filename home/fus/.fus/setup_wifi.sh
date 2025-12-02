#!/bin/zsh

# @file setup_wifi.sh
# @brief Advanced Wi-Fi Manager for Void Linux.
# @details - v13.0: UX Polish & Robustness.
#          - Fixes empty SSID in lists.
#          - Prevents duplicate network entries.
#          - Unified Scan logic.
#          - Proper input validation & Ctrl+C safety.
# @author Refactored by Gemini (based on ngxx.fus)
# @version 13.0

# --- [1] GLOBAL CONFIGURATION ---

# @var WIFI_DEV
WIFI_DEV="wlo1"

# @var WPA_CONF
WPA_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"

# @var BACKUP_DIR
BACKUP_DIR="/etc/wpa_supplicant"

# @var SESSION_FILE
SESSION_FILE="/tmp/wpa_session_$(date +%s).conf"

# @var SCAN_FILE
# @brief CSV format: RSSI|CH|MAC|SEC|SSID
SCAN_FILE="/tmp/wifi_scan_raw.tmp"

# @var ACTUAL_SAVE
# @brief 1=Clean, 0=Dirty (Unsaved changes)
ACTUAL_SAVE=1

# --- [2] UTILITIES ---

if [ -e /home/fus/.fus/shell_utils.sh ]; then 
    source /home/fus/.fus/shell_utils.sh 
else
    BOLD=$(tput bold); NORM=$(tput sgr0); 
    LRED=$(tput setaf 1); LGREEN=$(tput setaf 2); LYELLOW=$(tput setaf 3); 
    WHITE=$(tput setaf 7); GRAY=$(tput setaf 8);
fi

# @func global_trap
# @brief Exit script on Ctrl+C at main menu level.
global_trap() {
    echo ""
    echo "${LRED}[!] Script aborted.${NORM}"
    [ -f "$SESSION_FILE" ] && rm -f "$SESSION_FILE"
    [ -f "$SCAN_FILE" ] && rm -f "$SCAN_FILE"
    exit 130
}
trap global_trap SIGINT

# @func safe_read
# @brief Reads input while handling Ctrl+C gracefully (returns 130).
safe_read() {
    local _var_name="$1"
    local _prompt="$2"
    
    # Temporarily trap SIGINT to just return status 130
    trap 'return 130' SIGINT
    
    printf "${LYELLOW}${_prompt}${NORM}"
    read -r "$_var_name"
    local _ret=$?
    
    # Restore global trap
    trap global_trap SIGINT
    
    # Check if read was interrupted
    if [ $_ret -ne 0 ]; then
        echo ""
        echo "${LYELLOW}Cancelled.${NORM}"
        return 130
    fi
    return 0
}

# @func get_input_with_empty_check
# @brief Handles the logic: Empty -> "Retry? Y/N"
# @param $1 Prompt message
# @return 0 on success (result in $RET_VAL), 130 on cancel/Ctrl+C
get_input_with_empty_check() {
    local prompt="$1"
    RET_VAL=""
    
    while true; do
        safe_read INPUT "$prompt"
        if [ $? -eq 130 ]; then return 130; fi 
        
        if [[ -z "$INPUT" ]]; then
            echo "${LYELLOW}Input is empty.${NORM}"
            safe_read CONFIRM "Do you want to retry? (y/n): "
            if [ $? -eq 130 ]; then return 130; fi
            
            if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
                continue # Loop back to prompt
            else
                return 130 # Treat 'No' as cancel
            fi
        else
            RET_VAL="$INPUT"
            return 0
        fi
    done
}

do_you_want_to_continue(){
    local msg="${1:-Do you want to ${BOLD}continue${NORM}?}"
    echo "$msg (y/n)"
    safe_read ANS "Answer: "
    [ $? -eq 130 ] && return 1
    case $ANS in
        [Yy]*) return 0 ;;
        *) return 1 ;;
    esac
}

check_dependencies() {
    local deps=(iw wpa_supplicant wpa_passphrase ip grep awk sed cp mv pkill id chown rm sort timeout sync cmp)
    for cmd in $deps; do
        if ! command -v $cmd > /dev/null; then
            echo "${LRED}[ERROR] Required command '$cmd' not found.${NORM}"
            exit 1
        fi
    done
    if ! command -v dhcpcd >/dev/null && ! command -v dhclient >/dev/null; then
        echo "${LRED}[ERROR] No DHCP client found.${NORM}"
        exit 1
    fi
}

# --- [3] SESSION HANDLING ---

load_session() {
    if [ ! -f "$WPA_CONF" ]; then sudo touch "$WPA_CONF"; fi
    if sudo cp "$WPA_CONF" "$SESSION_FILE"; then
        sudo chown $(id -u):$(id -g) "$SESSION_FILE"
        chmod 600 "$SESSION_FILE"
    else
        echo "${LRED}Load failed.${NORM}"; exit 1
    fi
    ACTUAL_SAVE=1
}

print_header() {
    echo "${BOLD}--- WI-FI MANAGER CONFIGURATION ---${NORM}"
    echo "Interface   : ${LGREEN}${WIFI_DEV}${NORM}"
    echo "Real Config : ${GRAY}${WPA_CONF}${NORM}"
    echo "Session File: ${GRAY}${SESSION_FILE}${NORM}"
    echo "-----------------------------------"
    echo "${GRAY}[Session] Loaded Content:${NORM}"
    
    if [ -f "$SESSION_FILE" ]; then
        # Use simple cat to preserve exact file structure (headers included)
        cat "$SESSION_FILE"
    fi
    echo "${LGREEN}[Session] Ready.${NORM}"
}

save_to_disk() {
    echo "${LYELLOW}[Disk] Saving...${NORM}"
    local timestamp=$(date "+%Y%m%d_%H%M%S")
    local backup="${BACKUP_DIR}/wpa_supplicant.conf.bak_${timestamp}"
    
    if ! sudo cp "$WPA_CONF" "$backup"; then
        echo "${LRED}Backup failed.${NORM}"; return 1
    fi
    
    if sudo cp "$SESSION_FILE" "$WPA_CONF"; then
        sudo chmod 600 "$WPA_CONF"
        sync
        echo "${LGREEN}Saved successfully!${NORM}"
        ACTUAL_SAVE=1
        return 0
    else
        echo "${LRED}Write failed.${NORM}"; return 1
    fi
}

# --- [4] SHARED SCAN LOGIC ---

# @func perform_scan_and_cache
# @brief Scans wifi, parses data robustly, saves to CSV: RSSI|CH|MAC|SEC|SSID
perform_scan_and_cache() {
    echo "${GRAY}Scanning...${NORM}"
    sudo ip link set ${WIFI_DEV} up
    
    # AWK Logic: 
    # 1. Capture BSS block.
    # 2. Extract SSID. If empty or just spaces -> Mark [Hidden].
    # 3. Print only valid entries to file.
    sudo iw dev ${WIFI_DEV} scan | awk '
    BEGIN { mac="N/A"; rssi="-999"; ssid="[Hidden]"; freq="0"; sec="OPEN" }
    /^BSS / { 
        if (mac != "N/A") print rssi "|" freq "|" mac "|" sec "|" ssid
        mac=substr($2, 1, 17)
        rssi="-999"; ssid="[Hidden]"; freq="0"; sec="OPEN"
    }
    /freq:/ { freq=$2 }
    /signal:/ { rssi=int($2) }
    /SSID:/ { 
        # Robust SSID extraction: everything after "SSID: "
        val=substr($0, index($0, $2))
        # Trim leading/trailing whitespace (optional but good)
        gsub(/^[ \t]+|[ \t]+$/, "", val)
        
        if (length(val) > 0) ssid=val
        else ssid="[Hidden]"
    }
    /RSN:/ || /WPA:/ { sec="WPA" }
    END { if (mac != "N/A") print rssi "|" freq "|" mac "|" sec "|" ssid }
    ' | sort -t"|" -k1rn > "$SCAN_FILE"
}

# --- [5] MENU ACTIONS ---

# 1. Scan available
action_scan() {
    echo "${LYELLOW}[1] Scanning Available Networks...${NORM}"
    perform_scan_and_cache
    
    printf "${BOLD}  %-4s %-4s %-17s %-5s %-s${NORM}\n" "RSSI" "CH" "BSSID (MAC)" "SEC" "SSID"
    echo "  -------------------------------------------------------"
    
    awk -F"|" '{
        ch = ($2 - 2407) / 5
        if (ch < 1 || ch > 14) ch="5G"
        printf "  %-4s %-4s %-17s %-5s %s\n", $1, ch, $3, $4, $5
    }' "$SCAN_FILE"
    echo ""
}

# 2. List saved
action_list_saved() {
    echo "${LYELLOW}[2] Saved Networks (Session)${NORM}"
    awk '
    BEGIN { count=0 }
    /network=\{/ { in_block=1; ssid="N/A"; bssid="ANY"; psk="Encrypted" }
    /ssid="/ { if(in_block) { match($0, /ssid="([^"]+)"/, arr); ssid=arr[1] } }
    /bssid=/ { if(in_block) { match($0, /bssid=([0-9a-fA-F:]+)/, arr); bssid=arr[1] } }
    /#psk="/ { if(in_block) { match($0, /#psk="([^"]+)"/, arr); psk=arr[1] " (Plain)" } }
    /\}/ { if(in_block) { printf "  %2d. SSID: %-20s | MAC: %-17s | PASS: %s\n", ++count, ssid, bssid, psk; in_block=0 } }
    ' "$SESSION_FILE"
    echo ""
}

# 3. Add New Network
action_add_network() {
    echo "${LYELLOW}[3] Add New Network${NORM}"
    perform_scan_and_cache
    
    # Filter unique SSIDs, remove Hidden
    local MENU_FILE="${SCAN_FILE}.menu"
    awk -F"|" '$5 != "[Hidden]" { print $5 }' "$SCAN_FILE" | awk '!seen[$0]++' > "$MENU_FILE"
    
    echo "${BOLD}Available Networks:${NORM}"
    echo "   ${WHITE}0. Manual Entry (Hidden Network)${NORM}"
    
    if [ -s "$MENU_FILE" ]; then
        nl -w4 -s". " "$MENU_FILE"
    else
        echo "   (No networks found via scan)"
    fi
    
    safe_read CHOICE "Select Network Number (b to back): "
    [ $? -eq 130 ] && return
    [[ "$CHOICE" == "b" || -z "$CHOICE" ]] && return
    
    local SEL_SSID=""
    
    # Selection Logic
    if [[ "$CHOICE" == "0" ]]; then
        get_input_with_empty_check "Enter Manual SSID"
        [ $? -ne 0 ] && return
        SEL_SSID="$RET_VAL"
    else
        # Validate integer input
        if [[ ! "$CHOICE" =~ ^[0-9]+$ ]]; then
             echo "${LRED}Invalid input.${NORM}"; return
        fi
        
        SEL_SSID=$(sed -n "${CHOICE}p" "$MENU_FILE")
        if [[ -z "$SEL_SSID" ]]; then echo "${LRED}Invalid selection.${NORM}"; return; fi
    fi
    
    echo "${LGREEN}Selected: ${WHITE}$SEL_SSID${NORM}"
    
    # Check Duplicates
    if grep -q "ssid=\"$SEL_SSID\"" "$SESSION_FILE"; then
        echo "${LYELLOW}Warning: Network '$SEL_SSID' already exists.${NORM}"
        if ! do_you_want_to_continue "Add anyway?"; then return; fi
    fi
    
    # Password Input
    get_input_with_empty_check "Enter Password"
    [ $? -ne 0 ] && return
    local PASS="$RET_VAL"
    
    # Generate Block
    local BLOCK=$(wpa_passphrase "$SEL_SSID" "$PASS")
    if [ -s "$SESSION_FILE" ] && [ "$(tail -c1 "$SESSION_FILE" | wc -l)" -eq 0 ]; then echo "" >> "$SESSION_FILE"; fi
    echo "$BLOCK" >> "$SESSION_FILE"
    
    echo "${LGREEN}Added '$SEL_SSID'.${NORM}"
    ACTUAL_SAVE=0
    rm -f "$MENU_FILE"
}

# 4. Modify
get_ssid_at_index() { awk '/ssid="/ { match($0, /ssid="([^"]+)"/, arr); print arr[1] }' "$SESSION_FILE" | sed -n "${1}p"; }
delete_block() {
    awk -v t="$1" 'BEGIN{p=1;f=0} /network=\{/{p=0;b=$0;next} !p{b=b "\n" $0; if($0~/^\}/){if(index(b,"ssid=\"" t "\"")==0) print b; else f=1; p=1; b=""} next} p{print} END{exit !f}' "$SESSION_FILE" > "${SESSION_FILE}.tmp"
    if [ $? -eq 0 ]; then mv "${SESSION_FILE}.tmp" "$SESSION_FILE"; ACTUAL_SAVE=0; return 0; else return 1; fi
}

action_modify() {
    action_list_saved
    safe_read IDX "Select Index to Modify (b to back): "
    [ $? -eq 130 ] && return
    [[ "$IDX" == "b" || -z "$IDX" ]] && return
    
    local TARGET=$(get_ssid_at_index "$IDX")
    [[ -z "$TARGET" ]] && echo "${LRED}Invalid.${NORM}" && return
    
    echo "${WHITE}Target: $TARGET${NORM}"
    echo "  1. Edit SSID"
    echo "  2. Edit MAC (Lock BSSID)"
    echo "  3. Edit Password"
    echo "  4. Delete"
    echo "  5. Back"
    safe_read ACT "Action: "
    [ $? -eq 130 ] && return
    
    case $ACT in
        1) 
            get_input_with_empty_check "New SSID"; [ $? -ne 0 ] && return; NEW_S="$RET_VAL"
            get_input_with_empty_check "Re-enter Password"; [ $? -ne 0 ] && return; NEW_P="$RET_VAL"
            if delete_block "$TARGET"; then
                echo "$(wpa_passphrase "$NEW_S" "$NEW_P")" >> "$SESSION_FILE"
                echo "${LGREEN}Updated.${NORM}"
            fi
            ;;
        2)
            safe_read NEW_B "New BSSID (Leave empty to unlock): "
            [ $? -eq 130 ] && return 
            
            get_input_with_empty_check "Re-enter Password"; [ $? -ne 0 ] && return; NEW_P="$RET_VAL"
            if delete_block "$TARGET"; then
                BLOCK=$(wpa_passphrase "$TARGET" "$NEW_P")
                [[ -n "$NEW_B" ]] && BLOCK=$(echo "$BLOCK" | sed "s/}/    bssid=$NEW_B\n}/")
                echo "$BLOCK" >> "$SESSION_FILE"
                echo "${LGREEN}Updated.${NORM}"
            fi
            ;;
        3)
            get_input_with_empty_check "New Password"; [ $? -ne 0 ] && return; NEW_P="$RET_VAL"
            if delete_block "$TARGET"; then
                echo "$(wpa_passphrase "$TARGET" "$NEW_P")" >> "$SESSION_FILE"
                echo "${LGREEN}Updated.${NORM}"
            fi
            ;;
        4)
            if do_you_want_to_continue "Delete '$TARGET'?"; then
                delete_block "$TARGET"
                echo "${LGREEN}Deleted.${NORM}"
            fi
            ;;
    esac
}

# 5. Connect
action_connect() {
    echo "${LYELLOW}[5] Connecting...${NORM}"
    
    echo "${GRAY}   Stopping conflicts...${NORM}"
    sudo pkill -9 NetworkManager 2>/dev/null
    sudo pkill -9 wpa_supplicant 2>/dev/null
    sudo pkill -9 dhcpcd 2>/dev/null
    sudo pkill -9 dhclient 2>/dev/null
    sudo rm -rf /run/wpa_supplicant 2>/dev/null
    sleep 1
    
    echo "${GRAY}   Starting wpa_supplicant...${NORM}"
    sudo wpa_supplicant -B -i ${WIFI_DEV} -c "$WPA_CONF"
    
    printf "${LYELLOW}   Waiting for association (Max 3s): ${NORM}"
    local t=0; local conn=0
    while [ $t -lt 3 ]; do
        if sudo iw dev ${WIFI_DEV} link | grep -q "SSID:"; then conn=1; break; fi
        printf "."; sleep 1; t=$((t+1))
    done
    echo ""
    
    if [ $conn -eq 1 ]; then
        local LINK=$(sudo iw dev ${WIFI_DEV} link)
        local S=$(echo "$LINK" | awk '/SSID:/ {print $2}')
        local M=$(echo "$LINK" | awk '/Connected to/ {print $3}')
        local F=$(echo "$LINK" | awk '/freq:/ {print $2}')
        echo "${LGREEN}   [OK] Linked: $S ($M) @ ${F}MHz${NORM}"
        
        printf "${LYELLOW}   Requesting IP (Max 5s)...${NORM}"
        if command -v dhcpcd >/dev/null; then sudo timeout 5 dhcpcd -b ${WIFI_DEV} >/dev/null 2>&1
        elif command -v dhclient >/dev/null; then sudo timeout 5 dhclient ${WIFI_DEV} >/dev/null 2>&1; fi
        
        if ip a show ${WIFI_DEV} | grep -q "inet "; then
            local IP=$(ip a show ${WIFI_DEV} | grep "inet " | awk '{print $2}')
            echo "\n${LGREEN}   [OK] IP: $IP${NORM}"
        else
            echo "\n${LRED}   [FAIL] DHCP timeout.${NORM}"
        fi
    else
        echo "${LRED}   [FAIL] Not Associated.${NORM}"
    fi
}

# --- [7] MAIN LOOP ---

check_dependencies
load_session
print_header

while true; do
    echo "
${WHITE}========================================
   WIFI MANAGER v13.0
========================================${NORM}
  1. Scan available network(s)
  2. List saved network(s)
  3. Add New Network
  4. Modify saved network
  5. Restart network service (Connect)
  6. Save
  7. Exit
"
    safe_read OPTION "Select: "
    [ $? -eq 130 ] && echo "" && continue 

    case $OPTION in
        1) action_scan ;;
        2) action_list_saved ;;
        3) action_add_network ;;
        4) action_modify ;;
        5) action_connect ;;
        6) save_to_disk ;;
        7) 
            echo "${LYELLOW}Exiting...${NORM}"
            if [ $ACTUAL_SAVE -eq 0 ]; then
                if do_you_want_to_continue "Unsaved changes detected. Save?"; then
                    save_to_disk
                else
                    echo "${LRED}Discarded.${NORM}"
                fi
            fi
            [ -f "$SESSION_FILE" ] && rm -f "$SESSION_FILE"
            [ -f "$SCAN_FILE" ] && rm -f "$SCAN_FILE"
            exit 0 
            ;;
        *) echo "${LRED}Invalid.${NORM}" ;;
    esac
    echo ""
done
