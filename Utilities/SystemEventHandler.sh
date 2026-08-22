#!/bin/sh

# Evaluate if the user requested the help menu
case "$1" in
    -h|--help)
        echo "Usage: $0 [action]"
        echo ""
        echo "Actions:"
        echo "  -vu, --volume-up, button/volumeup       Increase volume (accelerated)"
        echo "  -vd, --volume-down, button/volumedown   Decrease volume (accelerated)"
        echo "  -vm, --mute, button/mute                Toggle audio mute"
        echo "  -pwr,--power, button/power              Suspend/Sleep the system (zzz)"
        echo "  -h, --help                              Show this help message"
        # Terminate script successfully after displaying help
        exit 0
        ;;
esac

# /*
#  * @var ACCELERATE_FILE_PATH
#  * @brief Temporary file used to store the timestamp of the last volume key press.
#  */
export ACCELERATE_FILE_PATH=/tmp/.fus/ACPIAccelerate

# /*
#  * @var USER_FUS_SOCKET
#  * @brief Dynamically locates the DBus socket of the user's notification daemon (dunst).
#  */
export USER_FUS_SOCKET=$(cat /proc/$(pgrep -u fus -n dunst)/environ | tr '\0' '\n' | grep '^DBUS_SESSION_BUS_ADDRESS=' | cut -d= -f2-)

# /*
#  * @var PACTL
#  * @brief Path to the PulseAudio control binary.
#  */
export PACTL="/usr/bin/pactl"

# /*
#  * @var DEF_SINK
#  * @brief Retrieves the default audio sink (Speaker/Headphone) for user 'fus'.
#  */
export DEF_SINK=$(sudo -u fus \
    XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
    "$PACTL" get-default-sink)

# /*
#  * @var SVOLUME_VALUE
#  * @brief Retrieves the current volume percentage (0-100) of the default sink.
#  */
export SVOLUME_VALUE=$(sudo -u fus \
    XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
    "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')

export delta_v=0
export delta_t=0 

# /*
#  * @func write_noti
#  * @brief Sends a desktop notification to the user session.
#  * @param $1 Summary/Title
#  * @param $2 Body/Message
#  * @param $3... Additional arguments for notify-send
#  */
write_noti() {
    sudo -u fus DBUS_SESSION_BUS_ADDRESS="$USER_FUS_SOCKET" notify-send "$1" "$2" $3 $4 $5 $6
}

cur_time=$(date +%s%3N)

# Evaluate if the acceleration file exists for timestamp calculation
if [ -e "$ACCELERATE_FILE_PATH" ]; then
    last_time=$(cat "$ACCELERATE_FILE_PATH")
    export delta_t=$((cur_time - last_time))
else
    export delta_v=1  
fi

echo "$cur_time" > "$ACCELERATE_FILE_PATH"

# Evaluate the delay threshold for volume acceleration
if [ $delta_t -gt 300 ]; then 
    export delta_v=1 
else
    # Evaluate for medium tap speed
    if [ $delta_t -gt 129 ]; then 
        export delta_v=2
    else 
        # Evaluate for fast tap speed
        if [ $delta_t -gt 125 ]; then 
            export delta_v=3 
        else
            # Critical speed (Holding)
            export delta_v=5
        fi
    fi
fi

# /*
#  * @func set_volume
#  * @brief Applies the new volume to PulseAudio.
#  * @param $1 Volume string (e.g., "50%")
#  */
set_volume() {
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-volume "$DEF_SINK" $1
}

# /*
#  * @func volume_up
#  * @brief Increases volume by 'delta_v', capped at 100%.
#  */
volume_up() {
    # Proceed to increase volume only if below maximum limit
    if [ $SVOLUME_VALUE -lt 100 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE+delta_v))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

# /*
#  * @func volume_down
#  * @brief Decreases volume by 'delta_v', floored at 0%.
#  */
volume_down() {
    # Proceed to decrease volume only if above minimum limit
    if [ $SVOLUME_VALUE -gt 0 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE-delta_v))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

# /*
#  * @func volume_mute_toggle
#  * @brief Toggles the mute state of the default sink.
#  */
volume_mute_toggle() {
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-mute "$DEF_SINK" toggle
}

# Evaluate primary event target
case "$1" in
    -vu|--volume-up|button/volumeup)
        volume_up
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    -vd|--volume-down|button/volumedown)
        volume_down
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    -vm|--mute|button/mute)
        volume_mute_toggle
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    -pwr|--power|button/power)
        logger "Power/Sleep button pressed. Suspending system..."
        zzz
        ;;
    *)
        logger "Action undefined: $1"
        echo "Invalid action. Use -h or --help for usage."
        # Terminate script with an error status for invalid arguments
        exit 1
        ;;
esac
