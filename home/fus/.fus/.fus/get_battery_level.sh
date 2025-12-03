#!/bin/zsh
# return 0
source /home/fus/.fus/shell_utils.sh

bat_icons=( 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹 )
bat_charging_icons=(󰢜 󰂆 󰂇 󰂈 󰢝 󰂉 󰢞 󰂊 󰂋 󰂅 )
bat_levels=( 10 20 30 40 50 60 70 80 90 101 )
bat_level=$(cat /sys/class/power_supply/BAT0/capacity)

bluez_bat_icon=󰂯
final_bluez_stat=
bluez_level=
bluez_dev_path=$(upower -e | grep headset)

if [ $? -eq 0 ] ; then 
    bluez_level=$(upower -i $bluez_dev_path | grep "percentage" | awk '{print $2}' | tr -d '%')
    final_bluez_stat=" | $bluez_bat_icon $bluez_level"
else
    bluez_dev_path=$(upower -e | grep handsfree)
    if [ $? -eq 0 ] ; then
        bluez_level=$(upower -i $bluez_dev_path | grep "percentage" | awk '{print $2}' | tr -d '%')
        final_bluez_stat=" | $bluez_bat_icon $bluez_level"
    else
        final_bluez_stat=
    fi
fi

for i in $( seq 1 10 ); do
    if [ $bat_level -lt ${bat_levels[$i]} ]; then
        if [ "$(cat /sys/class/power_supply/BAT0/status)" = "Charging" ]; then 
            echo "${bat_charging_icons[$i]} $bat_level$final_bluez_stat"
        else
            echo "${bat_icons[$i]} $bat_level$final_bluez_stat"
        fi
        break
    fi
done

