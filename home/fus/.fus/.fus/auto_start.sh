#!/bin/zsh
# @file autostart.sh
# @brief Background services.

echo "[auto_start.sh] Starting up..."

# --- SYSTEM SETUP ---
/usr/bin/picom --backend glx &
$HOME/.fus/setup_background.sh &
$HOME/.fus/init_display.sh &
/usr/local/bin/dwmblocks &

# --- INPUT METHOD ---
# @brief Restart fcitx5 to ensure it picks up variables from global_vars.sh
killall fcitx5 2>/dev/null
sleep 0.25
/bin/fcitx5 &


# --- MOUSE ---
if [ -f "$HOME/.fus/mouse_setup.sh" ]; then
    "$HOME/.fus/mouse_setup.sh" &
fi

# --- NOTIFICATION ---
sleep 1 
/usr/bin/notify-send -i /usr/share/icons/Adwaita/symbolic/emotes/face-smirk-symbolic.svg "[START-UP]" "Hello $(whoami)"

