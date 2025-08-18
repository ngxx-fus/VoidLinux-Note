#!/bin/zsh 

export BROWSER=firefox
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# export DBUS_SESSION_BUS_ADDRESS=$(lsof -U -p $(pgrep -u fus -n dbus-daemon) 2>/dev/null | awk '/\/tmp\/dbus-/{print $9; exit}')
# export DBUS_SESSION_BUS_ADDRESS=unix:path=$DBUS_SESSION_BUS_ADDRESS
