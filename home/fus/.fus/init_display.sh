
#!/bin/zsh

if [ -z "$_HDMI" ]; then
    export _HDMI=HDMI-1
fi

if [ -z "$_eDP" ]; then 
    export _eDP=eDP-1
fi


export _fus="/home/fus/.fus"
state_file="$_fus/monitor_mode"

APP_NAME="DisplayInit"
DEFAULT_NOTI_TIME=5000  # 2 seconds

# Initialize 
mode=1
echo "$mode" > "$state_file"
xrandr --output $_HDMI --off --output $_eDP --auto --primary
