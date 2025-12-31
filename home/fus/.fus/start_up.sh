## DEPRECATED ## #!/bin/zsh
## DEPRECATED ## 
## DEPRECATED ## pgrep dunst >> /dev/null
## DEPRECATED ## if [ $? -eq 0 ]; then
## DEPRECATED ##     kill $(pgrep dunst)
## DEPRECATED ## fi
## DEPRECATED ## /usr/bin/dunst  &
## DEPRECATED ## 
## DEPRECATED ## sleep 1 
## DEPRECATED ## 
## DEPRECATED ## # /usr/bin/notify-send "[START-UP]" "run: mount_external_ssd"
## DEPRECATED ## # exec /home/fus/.fus/mount_external_ssd.sh &
## DEPRECATED ## # if [ $? -gt 0 ] ; then 
## DEPRECATED ##     # /usr/bin/notify-send "[START-UP]" "mount_external_ssd: failed" --urgency=low
## DEPRECATED ## # fi
## DEPRECATED ## 
## DEPRECATED ## /usr/bin/notify-send -i /usr/share/icons/Adwaita/symbolic/emotes/face-smirk-symbolic.svg "[START-UP]" "Hello $(whoami)"
## DEPRECATED ## 
## DEPRECATED ## /usr/bin/notify-send "[START-UP]" "run: fcitx5-unikey"
## DEPRECATED ## kill $(pgrep fcitx5)
## DEPRECATED ## /bin/fcitx5 &
## DEPRECATED ## 
## DEPRECATED ## export DBUS_SESSION_BUS_ADDRESS=$(lsof -U -p $(pgrep -u fus -n dunst) 2>/dev/null | awk '/\/tmp\/dbus-/{print $9; exit}')
## DEPRECATED ## export DBUS_SESSION_BUS_ADDRESS=unix:path=$DBUS_SESSION_BUS_ADDRESS
## DEPRECATED ## 
## DEPRECATED ## 








