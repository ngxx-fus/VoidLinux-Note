#!/bin/zsh

source /home/fus/.fus/shell_utils.sh

bat_icons=( 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 )
bat_levels=( 10 20 30 40 50 60 70 80 90 100 )
bat_level=$(cat /sys/class/power_supply/BAT0/capacity)
final_bat_icon=

for i in $(seq 1 10); do
    if [ $bat_level -lt ${bat_levels[$i]} ]; then
        final_bat_icon=${bat_icons[$i]}
        if [ $bat_level -lt 40 ]; then
            final_bat_icon="\0x5$final_bat_icon"
        else
            [ $bat_level -lt 60 ] && final_bat_icon="\0x6$final_bat_icon"
        fi
        break
    fi
done

echo "$final_bat_icon $bat_level%\0x1"

