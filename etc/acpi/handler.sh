#LOCATION: /home/fus/.fus/get_acpi_msg.sh
#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys


# This function will write text into xsetroot of DWM (mod by FUS)
write_noti() {
    local msg="$*"
    su - fus -c "DISPLAY=:0 xsetroot -name '$msg'" &
}

# write_noti() {
#     local msg="$*"
#     echo "$msg" > /home/fus/.fus/.acpi_msg
#     su - fus -c "kill -RTMIN+1 \$(pidof dwmblocks)" &
# }


volume_up() {
    amixer set Master 1+
}

volume_down() {
    amixer set Master 1-
}

volume_mute_toggle() {
    amixer set Master toggle
}

volume_get() {
    amixer get Master | awk -F'[][]' '/dB/ { print $2; exit }'
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
                write_noti ">>> PowerButton is IGNORED >>>"
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
        write_noti ">>> AC_ADAPTER CHANGED >>>"
        case "$2" in
            AC|ACAD|ADP0)
                case "$4" in
                    00000000)
                        cat "$minspeed" >"$setspeed"
                        write_noti ">>> BATTERY MODE >>>"
                        #/etc/laptop-mode/laptop-mode start
                    ;;
                    00000001)
                        cat "$maxspeed" >"$setspeed"
                        write_noti ">>> ADAPTER MODE >>>"
                        #/etc/laptop-mode/laptop-mode stop
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
        write_noti "󰃞  [-] [$(get_brightness)]"
        ;;
    video/brightnessup)
        step_backlight +
        write_noti "󰃠  [+] [$(get_brightness)]"
        ;;

    button/volumedown)
        volume_down
        write_noti "  [-] [$(volume_get)]"
        ;;
    button/volumeup)
        volume_up
        write_noti "  [+] [$(volume_get)]"
        ;;
    button/mute)
        volume_mute_toggle
        write_noti "  [x] [$(volume_get)]"
        ;;

    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;


esac
