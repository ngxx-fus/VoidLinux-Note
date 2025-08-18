#!/bin/zsh

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
    current_brightness=$(get_brightness)
    if [ $current_brightness -eq 0 ] || [ $current_brightness -eq 100 ] ; then
        return 0
    fi
    for backlight in /sys/class/backlight/*; do
        [ -d "$backlight" ] || continue
        step=$(( $(cat "$backlight/max_brightness") / 20 ))
        [ "$step" -gt "1" ] || step=1 #fallback if gradation is too low
        printf '%s' "$(( $(cat "$backlight/brightness") $1 step ))" >"$backlight/brightness"
    done
}

if [ $# -gt 1 ]; then
    echo "Too many args, please try again!"
fi

case $1 in 
    --up) 
        step_backlight +
        ;;
    --down) 
        step_backlight -
        ;;
    --get-value)
        echo "$(get_brightness)"
        ;;
    *)
        echo "$@"
        echo "Usage: --up | --down | --get_value"
esac
