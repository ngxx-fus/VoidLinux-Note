
#!/bin/zsh

if [ -z "$_HDMI" ]; then
    export _HDMI=HDMI1
fi

if [ -z "$_eDP" ]; then 
    export _eDP=eDP1
fi

# export _fus="/home/fus/.fus"
state_file="/tmp/.fus/monitor_mode"

# Initialize
mode=1
mkdir -p /tmp/.fus/
echo "$mode" > "$state_file"
xrandr --output $_HDMI --off --output $_eDP --auto --primary
