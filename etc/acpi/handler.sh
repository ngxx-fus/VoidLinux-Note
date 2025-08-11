#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

# This function will write text into xsetroot of DWM (mod by FUS)
write_noti() {
    local msg="$*"
    su - fus -c "DISPLAY=:0 xsetroot -name '$msg'" &
}

PACTL=/usr/bin/pactl
AMIXER=/usr/bin/amixer

export DEF_SINK=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-default-sink)

export SVOLUME_VALUE=$(sudo -u fus \
  XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
  "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')

set_volume(){
    sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
                DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
                "$PACTL" set-sink-volume "$DEF_SINK" $1
}

volume_up() {
    if [ -e $PACTL ]; then 
        if [ $SVOLUME_VALUE -lt 100 ]; then
            SVOLUME_VALUE=$((SVOLUME_VALUE+1))
            set_volume "${SVOLUME_VALUE}%"
        fi
    else 
        amixer set Master 1+
    fi
}

volume_down() {
    if [ -e $PACTL ]; then 
        if [ $SVOLUME_VALUE -gt 0 ]; then
            SVOLUME_VALUE=$((SVOLUME_VALUE-1))
            set_volume "${SVOLUME_VALUE}%"
        fi
    else 
        amixer set Master 1-
    fi
}

volume_mute_toggle() {
    if [ -e $PACTL ]; then 
        sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
            DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
            "$PACTL" set-sink-mute "$DEF_SINK" toggle
    else 
        amixer set Master toggle
    fi
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
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        cat "$minspeed" >"$setspeed"
                    ;;
                    00000001)
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
        # write_noti "󰃞  [-] [$(get_brightness)]"
        pkill -RTMIN+17 dwmblocks
        ;;
    video/brightnessup)
        step_backlight +
        pkill -RTMIN+17 dwmblocks
        # write_noti "󰃠  [+] [$(get_brightness)]"
        ;;

    button/volumedown)
        volume_down
        pkill -RTMIN+15 dwmblocks
        # write_noti "  [$SVOLUME_VALUE]"
        ;;
    button/volumeup)
        volume_up
        pkill -RTMIN+15 dwmblocks
        # write_noti "  [$SVOLUME_VALUE]"
        ;;
    button/mute)
        volume_mute_toggle
        # write_noti "  [$SVOLUME_VALUE]"
        ;;

    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;


esac
