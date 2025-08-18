#!/bin/zsh

export _fus="/home/fus/.fus"

state_file="$_fus/monitor_mode"
join_mode="$_fus/screenjoin.sh"

APP_NAME="DisplaySwitcher"
DEFAULT_NOTI_TIME=5000  # 2 seconds

if [ -z "$_HDMI" ]; then
    export _HDMI=HDMI-1
fi

if [ -z "$_eDP" ]; then 
    export _eDP=eDP-1
fi

# Function to send desktop notifications
# Arguments: $1=title, $2=message, $3=urgency (low, normal, critical), $4=timeout_ms (optional), $5=icon_path (optional)
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"
    local timeout_ms="${4:-$DEFAULT_NOTI_TIME}"
    local icon_path="$5"

    local cmd_args=(
        notify-send
        -a "$APP_NAME"
        -u "$urgency"
        -t "$timeout_ms"
    )

    [ -n "$icon_path" ] && cmd_args+=(-i "$icon_path")

    cmd_args+=("$title" "$message")

    "${cmd_args[@]}"
}

# Initialize or increment mode
if [ ! -f "$state_file" ]; then
    mode=1
else
    mode=$(cat "$state_file")
    mode=$((mode + 1))
    [ "$mode" -gt 4 ] && mode=1
fi

echo "$mode" > "$state_file"

# Run the corresponding mode
case "$mode" in
    1)
        send_notification "Display Mode" "Mode 1: Built-in only (${_eDP})" normal
        xrandr --output ${_HDMI} --off --output ${_eDP} --auto --primary
        ;;
    2)
        send_notification "Display Mode" "Mode 2: External only (${_HDMI})" normal
        xrandr --output ${_eDP} --off --output ${_HDMI} --mode 1920x1080 --rate 60 --primary
        ;;
    3)
        send_notification "Display Mode" "Mode 3: Join (dual monitor layout)" normal
        if [ -x "$join_mode" ]; then
            "$join_mode"
        else
            send_notification "Display Mode" "Join config not found: $join_mode" critical
        fi
        ;;
    4)
        send_notification "Display Mode" "Mode 4: Mirror (duplicate displays)" normal
        xrandr --output ${_eDP} --auto --output ${_HDMI} --auto --same-as eDP1
        ;;
esac

# Re-set-up Background picture
exec $_fus/setup_background.sh
