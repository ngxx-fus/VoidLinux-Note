#!/bin/zsh

pgrep dunst >> /dev/null
if [ $? -eq 0 ]; then
    kill $(pgrep dunst)
fi
/usr/bin/dunst  &

sleep 1 

/usr/bin/notify-send "[START-UP]" "run: mount_external_ssd"
exec /home/fus/.fus/mount_external_ssd.sh &

/usr/bin/notify-send "[START-UP]" "run: fcitx5-unikey"
kill $(pgrep fcitx5)
/bin/fcitx5 &

export DBUS_SESSION_BUS_ADDRESS=$(lsof -U -p $(pgrep -u fus -n dunst) 2>/dev/null | awk '/\/tmp\/dbus-/{print $9; exit}')
export DBUS_SESSION_BUS_ADDRESS=unix:path=$DBUS_SESSION_BUS_ADDRESS










