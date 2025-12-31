#!/bin/sh

# @file handler.sh
# @brief Default ACPI event handler script tailored for user 'fus'.
# @author Modified by NGXXFUS (13 August 2025)
# @details Handles system events (Power, Lid, Battery, AC) and input events (Volume, Brightness, Media).
# @note This script runs as ROOT (invoked by acpid). Commands targeting the user session (audio, notifications)
#       use 'sudo -u fus' with explicit DBUS/Runtime path exports to bridge the permission gap.

# --- GLOBAL CONFIGURATION & EXPORTS ---

# @var ACCELERATE_FILE_PATH
# @brief Temporary file used to store the timestamp of the last volume key press.
export ACCELERATE_FILE_PATH=/tmp/.fus/acpi_accelerate

# @var USER_FUS_SOCKET
# @brief Dynamically locates the DBus socket of the user's notification daemon (dunst).
# @details Used to send 'notify-send' messages from Root to the User's desktop.
export USER_FUS_SOCKET=$(sudo lsof -U -p $(pgrep -u fus -n dunst) 2>/dev/null | awk '/\/tmp\/dbus-/{print $9; exit}')

# @var PACTL
# @brief Path to the PulseAudio control binary.
export PACTL="/usr/bin/pactl"

# @var DEF_SINK
# @brief Retrieves the default audio sink (Speaker/Headphone) for user 'fus'.
# @note Explicitly defines XDG_RUNTIME_DIR and DBUS_SESSION_BUS_ADDRESS to access user's PulseAudio daemon.
export DEF_SINK=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-default-sink)

# @var SVOLUME_VALUE
# @brief Retrieves the current volume percentage (0-100) of the default sink.
# @details Parses 'pactl get-sink-volume' output using awk to strip formatting.
export SVOLUME_VALUE=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')

# @var delta_v
# @brief Volume change step size (default 0). Adjusted dynamically based on press speed.
export delta_v=0

# @var delta_t
# @brief Time difference (in ms) between the current and previous key press.
export delta_t=0 

# --- HELPER FUNCTIONS ---

# @func write_noti
# @brief Sends a desktop notification to the user session.
# @param $1 Summary/Title
# @param $2 Body/Message
# @param $3... Additional arguments for notify-send (e.g., --urgency, --icon)
write_noti() {
    sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET notify-send "$1" "$2" $3 $4 $5 $6
}

###################################################################################
# @section Volume Acceleration Algorithm
# @brief Calculates dynamic step size (delta_v) based on key press frequency.
# @details
#   1. Gets current time in milliseconds.
#   2. Reads previous time from temp file.
#   3. Calculates delta_t = current - last.
#   4. Determines step size (delta_v) based on thresholds.
#
# @example Logic Table:
#   - delta_t > 300ms (Slow tap)    -> delta_v = 1 (Fine tuning)
#   - delta_t > 129ms (Medium tap)  -> delta_v = 2
#   - delta_t > 125ms (Fast tap)    -> delta_v = 3
#   - delta_t <= 125ms (Holding)    -> delta_v = 5 (Fast scroll)
###################################################################################

cur_time=$(date +%s%3N)
if [ -e "$ACCELERATE_FILE_PATH" ]; then
    last_time=$(cat "$ACCELERATE_FILE_PATH")
    export delta_t=$((cur_time - last_time))
else
    # @brief First run case or file missing
    export delta_v=1  
fi

# @brief Save current timestamp for the next iteration
echo "$cur_time" > "$ACCELERATE_FILE_PATH"

if [ $delta_t -gt 300 ]; then 
    export delta_v=1 
else
    if [ $delta_t -gt 129 ]; then 
        export delta_v=2
    else 
        if [ $delta_t -gt 125 ]; then 
            export delta_v=3 
        else
            # @brief Critical speed (User is likely holding the key down)
            # write_noti "[Warning]" "Volume is changing too fast!!!" "--urgency=critical" "--expire-time=2000"
            export delta_v=5
        fi
    fi
fi

###################################################################################

# @func set_volume
# @brief Applies the new volume to PulseAudio.
# @param $1 Volume string (e.g., "50%", "+5%").
set_volume(){
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-volume "$DEF_SINK" $1
}

# @func volume_up
# @brief Increases volume by 'delta_v', capped at 100%.
volume_up() {
    if [ $SVOLUME_VALUE -lt 100 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE+delta_v))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

# @func volume_down
# @brief Decreases volume by 'delta_v', floored at 0%.
volume_down() {
    if [ $SVOLUME_VALUE -gt 0 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE-delta_v))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

# @func volume_mute_toggle
# @brief Toggles the mute state of the default sink.
volume_mute_toggle() {
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-mute "$DEF_SINK" toggle
}

# @func get_brightness
# @brief Calculates current backlight percentage.
# @return Prints percentage (0-100) or "N/A".
get_brightness() {
    for backlight in /sys/class/backlight/*; do
        [ -d "$backlight" ] || continue
        max=$(cat "$backlight/max_brightness")
        current=$(cat "$backlight/brightness")
        percent=$(( current * 100 / max ))
        echo "$percent"
        return 0
    done
    echo "N/A"
    return 1
}

# @func step_backlight
# @brief Adjusts backlight brightness via sysfs.
# @param $1 Operator ('+' or '-')
step_backlight() {
    for backlight in /sys/class/backlight/*/; do
        [ -d "$backlight" ] || continue
        # @brief Calculate step size (5% of max brightness)
        step=$(( $(cat "$backlight/max_brightness") / 20 ))
        [ "$step" -gt "1" ] || step=1 # fallback if gradation is too low
        
        # @brief Write new value to sysfs (Requires Root)
        printf '%s' "$(( $(cat "$backlight/brightness") $1 step ))" >"$backlight/brightness"
    done
}

# @var CPU Frequency Paths
# @brief Sysfs paths for controlling CPU frequency.
minspeed="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq"
maxspeed="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

# --- MAIN EVENT LOOP ---
# @param $1 ACPI Group (button/power, ac_adapter, etc.)
# @param $2 ACPI Action (PBTN, AC, etc.)

case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger "PowerButton pressed: $2, pypass to suspending :>"
                # @brief Execute suspend-to-ram (void linux specific tool)
                zzz
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SBTN|SLPB)
                # suspend-to-ram
                logger "Sleep Button pressed: $2, suspending..."
                zzz
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    ac_adapter)
        # @brief Signal dwmblocks to update status bar immediately
        pkill -RTMIN+16 dwmblocks
        case "$2" in
            AC|ACAD|ADP0|ACPI0003:00)
                case "$4" in
                    00000000)
                        # @brief Adapter Unplugged -> Notify & Set CPU to Min speed
                        write_noti "[AC_ADAPTER]"  "unplugged" "--urgency=low" "--expire-time=5000"
                        cat "$minspeed" >"$setspeed"
                    ;;
                    00000001)
                        # @brief Adapter Plugged -> Notify & Set CPU to Max speed
                        write_noti "[AC_ADAPTER] plugged" "--urgency=low" "--expire-time=5000"
                        cat "$maxspeed" >"$setspeed"
                    ;;
                esac
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)   #echo "offline" >/dev/tty5
                    ;;
                    00000001)   #echo "online"  >/dev/tty5
                    ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                # @brief Lid Close Event -> Suspend
                logger "LID closed, suspending..."
                zzz
                ;;
            open)
                logger "LID opened"
                ;;
            *)  logger "ACPI action undefined (LID): $2";;
        esac
        ;;
    video/brightnessdown)
        step_backlight -
        # @brief Signal dwmblocks (Sig 17) to update brightness module
        write_noti "[ACPI-NOTIFICATION]" "󰃞  [$(get_brightness)]" "--urgency=normal" "--expire-time=1000"
        pkill -RTMIN+17 dwmblocks
        ;;
    video/brightnessup)
        step_backlight +
        pkill -RTMIN+17 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "󰃠  [$(get_brightness)]" "--urgency=normal" "--expire-time=1000"
        ;;

    button/volumedown)
        volume_down
        # @brief Signal dwmblocks (Sig 15) to update volume module
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    button/volumeup)
        volume_up
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    button/mute)
        volume_mute_toggle
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]" "--urgency=normal" "--expire-time=1000"
        ;;
    # @brief Media Control Keys
    # @details Uses 'playerctl' to control MPRIS-compliant media players.
    cd/pause|cd/play2|cd/next|cd/prev)
        case "$2" in
            CDPAUSE)
                write_noti "[MEDIA]" "PAUSE" "--icon=multimedia-player"
                sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET  playerctl play-pause
                ;;
            CDPLAY2)
                write_noti "[MEDIA]" "PLAY" "--icon=multimedia-player"
                sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET  playerctl play-pause
                ;;
            CDNEXT)
                write_noti "[MEDIA]" "NEXT" "--icon=multimedia-player"
                sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET  playerctl next
                ;;
            CDPREV)
                write_noti "[MEDIA]" "PREVIOUS" "--icon=multimedia-player"
                sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET  playerctl previous
                ;;
        esac
        ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;

esac
