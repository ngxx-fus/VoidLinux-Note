
#!/bin/zsh

export _fus="/home/fus/.fus"
state_file="$_fus/monitor_mode"

APP_NAME="DisplayInit"
DEFAULT_NOTI_TIME=5000  # 2 seconds

# Initialize 
mode=1
echo "$mode" > "$state_file"
xrandr --output HDMI1 --off --output eDP1 --auto --primary
