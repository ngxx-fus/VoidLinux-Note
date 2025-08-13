#!/bin/sh
# MOD BY NGXXFUS - DATE: 13 August 2025 
# Default acpi script that takes an entry for all actions
# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

export USER_FUS_SOCKET=$(sudo lsof -U -p $(pgrep -u fus -n dunst) 2>/dev/null | awk '/\/tmp\/dbus-/{print $9; exit}')
export PACTL="/usr/bin/pactl"
export DEF_SINK=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-default-sink)
export SVOLUME_VALUE=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')

# This function will write text into xsetroot of DWM (mod by FUS)
write_noti() {
    sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET notify-send -t 1000 "$1" "$2" $3 $4
    # su - fus -c "DISPLAY=:0 xsetroot -name '$*'" &
}

set_volume(){
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-volume "$DEF_SINK" $1
}

volume_up() {
    if [ $SVOLUME_VALUE -lt 100 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE+1))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

volume_down() {
    if [ $SVOLUME_VALUE -gt 0 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE-1))
        set_volume "${SVOLUME_VALUE}%"
    fi
}

volume_mute_toggle() {
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-mute "$DEF_SINK" toggle
}

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


# $1 should be + or - to step up or down the brightness.
step_backlight() {
    for backlight in /sys/class/backlight/*/; do
        [ -d "$backlight" ] || continue
        step=$(( $(cat "$backlight/max_brightness") / 20 ))
        [ "$step" -gt "1" ] || step=1 #fallback if gradation is too low
        printf '%s' "$(( $(cat "$backlight/brightness") $1 step ))" >"$backlight/brightness"
    done
}

minspeed="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq"
maxspeed="/sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq"
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"


case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger "PowerButton pressed: $2, pypass to suspending :>"
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
        pkill -RTMIN+16 dwmblocks
        case "$2" in
            AC|ACAD|ADP0|ACPI0003:00)
                case "$4" in
                    00000000)
                        write_noti "[AC_ADAPTER]"  "unplugged" -u low
                        cat "$minspeed" >"$setspeed"
                    ;;
                    00000001)
                        write_noti "[AC_ADAPTER] plugged"
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
                # suspend-to-ram
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
        write_noti "[ACPI-NOTIFICATION]" "󰃞  [$(get_brightness)]"
        pkill -RTMIN+17 dwmblocks
        ;;
    video/brightnessup)
        step_backlight +
        pkill -RTMIN+17 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "󰃠  [$(get_brightness)]"
        ;;

    button/volumedown)
        volume_down
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]"
        ;;
    button/volumeup)
        volume_up
        pkill -RTMIN+15 dwmblocks
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]"
        ;;
    button/mute)
        volume_mute_toggle
        write_noti "[ACPI-NOTIFICATION]" "  [$SVOLUME_VALUE]"
        ;;
    cd/pause|cd/play|cd/next|cd/prev)
        case "$2" in
            CDPAUSE)
                write_noti "[MEDIA]" "PAUSE" "--icon=multimedia-player"
                sudo -u fus DBUS_SESSION_BUS_ADDRESS=unix:path=$USER_FUS_SOCKET  playerctl play-pause
                ;;
            CDPLAY)
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
