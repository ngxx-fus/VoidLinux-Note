# GLOBAL VARS #################################################################
export _HDMI=$(xrandr | grep -E '^HDMI[-0-9]* connected' | awk '{print $1}')
export _eDP=$(xrandr | grep -E '^eDP[-0-9]* connected' | awk '{print $1}')
export BROWSER=firefox
export XDG_RUNTIME_DIR=/run/user/$(id -u)
# export XDG_RUNTIME_DIR=/run/user/1000
export ROFI_PNG_OUTPUT=/home/fus/Pictures/Rofi-Captures.jpg
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
# START-UP APP ################################################################
exec /home/fus/.fus/disable_built_in_keyboard.sh        					&
exec /usr/bin/picom --backend glx                       					&
exec /home/fus/.fus/setup_background.sh                 					&
exec /home/fus/.fus/init_display.sh                     					&
exec /usr/local/bin/dwmblocks                           					&
# exec /home/fus/.fus/mount_sdcard.sh                                         &
exec /home/fus/.fus/mount_external_ssd.sh                                   &
# exec /etc/init.d/vmware start                                               &
# exec /etc/init.d/vmware-USBArbitrator start                                 &
# exec /home/fus/.fus/internet_check.sh                                       &
exec /usr/bin/fcitx5                                                        &
# DWM ######################################################################### 
exec dwm

