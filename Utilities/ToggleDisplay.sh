#!/bin/zsh

# =================================================================================================
# @file ToggleDisplay.sh
# @brief Dynamic display output switcher for Raspberry Pi 5 dual-HDMI setup.
#
# @details
#  This script detects physical display connections and applies the corresponding layout.
#  If both monitors are connected, it cycles through 4 distinct display layout modes:
#    - Mode 1: Primary output only (HDMI-1 active, HDMI-2 disabled).
#    - Mode 2: Secondary output only (HDMI-2 active, HDMI-1 disabled).
#    - Mode 3: Dual monitor extension (HDMI-2 placed below HDMI-1).
#    - Mode 4: Display mirroring (HDMI-2 clones HDMI-1 output).
#  If only one monitor is connected, it forces that output and disables the other.
#
# @usage
#  - CLI execution:
#      ./Utilities/ToggleDisplay.sh
#  - DWM keybinding configuration (config.h):
#      static const char *toggledisplaycmd[] = { "/home/fus/.fus/Utilities/ToggleDisplay.sh", NULL };
#      ...
#      { MODKEY, XK_F7, spawn, {.v = toggledisplaycmd } },
#
# @setup_instructions
#  1. Physical Connection on Raspberry Pi 5:
#     - Connect the primary screen to micro-HDMI Port 0 (labeled HDMI0 -> detected as HDMI-1).
#     - Connect the secondary screen to micro-HDMI Port 1 (labeled HDMI1 -> detected as HDMI-2).
#  2. Override Port Names (Optional):
#     - Default ports are HDMI-1 and HDMI-2. To override them via environment variables:
#         export _HDMI1="HDMI-1"
#         export _HDMI2="HDMI-2"
#  3. Verification:
#     - Run `xrandr -q` to confirm connected outputs and available resolutions.
# =================================================================================================

export _fus="/home/fus/.fus"

# Path to state file tracking active display configuration
state_file="/tmp/.fus/MonitorMode"

# Ensure the state directory exists to prevent I/O errors
if [ ! -e "$state_file" ]; then
    mkdir -p /tmp/.fus
    echo "1" > "$state_file"
fi 

APP_NAME="DisplaySwitcher"
DEFAULT_NOTI_TIME=5000

# Set default ports for Raspberry Pi 5 dual HDMI outputs
if [ -z "$_HDMI1" ]; then
    export _HDMI1="HDMI-1"
fi

if [ -z "$_HDMI2" ]; then 
    export _HDMI2="HDMI-2"
fi

# -------------------------------------------------------------------------------------------------
# @brief Sends desktop notifications via notify-send.
#
# @param $1 Title of the notification.
# @param $2 Message body.
# @param $3 Urgency level (low, normal, critical).
# @param $4 Timeout in milliseconds (optional).
# @param $5 Icon path (optional).
# -------------------------------------------------------------------------------------------------
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"
    local timeout_ms="${4:-$DEFAULT_NOTI_TIME}"
    local icon_path="$5"

    local cmd_args=(
        notify-send
        -a "$APP_NAME"
        -u "$urgency"
        -t "$timeout_ms"
    )

    # Conditionally append icon path if provided
    if [ -n "$icon_path" ]; then
        cmd_args+=(-i "$icon_path")
    fi

    cmd_args+=("$title" "$message")

    "${cmd_args[@]}"
}

# -------------------------------------------------------------------------------------------------
# DISPLAY DETECTION & STEERING LOGIC
# -------------------------------------------------------------------------------------------------

# Detect connected physical displays using xrandr output parsing
HDMI1_STATE=$(xrandr | grep -c "^${_HDMI1} connected")
HDMI2_STATE=$(xrandr | grep -c "^${_HDMI2} connected")

# Steer logic based on the hardware connection states
if [ "$HDMI1_STATE" -eq 1 ] && [ "$HDMI2_STATE" -eq 1 ]; then
    
    # Check if state file exists to initialize or increment mode
    if [ ! -f "$state_file" ]; then
        mode=1
    else
        mode=$(cat "$state_file")
        mode=$((mode + 1))
        
        # Reset mode to 1 when exceeding the maximum state index (4)
        if [ "$mode" -gt 4 ]; then
            mode=1
        fi
    fi

    echo "$mode" > "$state_file"

    # Branch execution based on the active mode value
    case "$mode" in
        1)
            send_notification "Display Mode" "Mode 1: Primary output only (${_HDMI1})" normal
            xrandr --output "${_HDMI2}" --off --output "${_HDMI1}" --auto --primary
            
            # Break out of the case statement
            ;;
        2)
            send_notification "Display Mode" "Mode 2: Secondary output only (${_HDMI2})" normal
            xrandr --output "${_HDMI1}" --off --output "${_HDMI2}" --auto --primary
            
            # Break out of the case statement
            ;;
        3)
            send_notification "Display Mode" "Mode 3: Extended Desktop (1 on 2)" normal
            xrandr --output "${_HDMI1}" --auto --primary --output "${_HDMI2}" --auto --below "${_HDMI1}"
            
            # Break out of the case statement
            ;;
        4)
            send_notification "Display Mode" "Mode 4: Mirroring (${_HDMI1} clone to ${_HDMI2})" normal
            xrandr --output "${_HDMI1}" --auto --primary --output "${_HDMI2}" --auto --same-as "${_HDMI1}"
            
            # Break out of the case statement
            ;;
    esac

elif [ "$HDMI1_STATE" -eq 1 ]; then
    send_notification "Display Mode" "Only ${_HDMI1} connected" normal
    xrandr --output "${_HDMI1}" --auto --primary --output "${_HDMI2}" --off
    echo "1" > "$state_file"

elif [ "$HDMI2_STATE" -eq 1 ]; then
    send_notification "Display Mode" "Only ${_HDMI2} connected" normal
    xrandr --output "${_HDMI2}" --auto --primary --output "${_HDMI1}" --off
    echo "2" > "$state_file"

else
    send_notification "Display Mode" "No display detected. Headless mode (SSH)." critical
fi

# Transfer execution directly to the background setup utility
exec "${_fus}/Utilities/SetupBackgroun.sh"