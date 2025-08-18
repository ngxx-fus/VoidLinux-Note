# GLOBAL VARS #################################################################
export _HDMI=$(xrandr | grep -E '^HDMI[-0-9]* connected' | awk '{print $1}')
export _eDP=$(xrandr | grep -E '^eDP[-0-9]* connected' | awk '{print $1}')
export ROFI_PNG_OUTPUT=/home/fus/Pictures/Rofi-Captures.jpg

# START-UP APP ################################################################
exec /usr/bin/picom --backend glx                       					&
exec /home/fus/.fus/setup_background.sh                 					&
exec /home/fus/.fus/init_display.sh                     					&
exec /usr/local/bin/dwmblocks                           					&
exec /home/fus/.fus/start_up.sh                                             &
# DWM ######################################################################### 
exec dwm 
