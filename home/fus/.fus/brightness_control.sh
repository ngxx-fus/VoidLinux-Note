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
    for backlight in /sys/class/backlight/*/; do
        [ -d "$backlight" ] || continue
        step=$(( $(cat "$backlight/max_brightness") / 20 ))
        [ "$step" -gt "1" ] || step=1 #fallback if gradation is too low
        printf '%s' "$(( $(cat "$backlight/brightness") $1 step ))" >"$backlight/brightness"
    done
}


if [ $# -eq 0 ] || [ $# -gt 1 ]; then 
    echo "Usage: --up | --down | --get-value"
else
    case $1 in;
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
            echo "Usage: --up | --down | --get-value"
            ;;
    esac
fi
