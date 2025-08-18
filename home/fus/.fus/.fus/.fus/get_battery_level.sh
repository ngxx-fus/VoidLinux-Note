#!/bin/zsh
# return 0
source /home/fus/.fus/shell_utils.sh

bat_icons=( 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 )
bat_charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅 )
bat_levels=( 10 20 30 40 50 60 70 80 90 101 )
bat_level=$(cat /sys/class/power_supply/BAT0/capacity)

for i in $( seq 1 10 ); do
    if [ $bat_level -lt ${bat_levels[$i]} ]; then
        if [ "$(cat /sys/class/power_supply/BAT0/status)" = "Charging" ]; then 
            echo "${bat_charging_icons[$i]} $bat_level"
        else
            echo "${bat_icons[$i]} $bat_level"
        fi
        break
    fi
done

