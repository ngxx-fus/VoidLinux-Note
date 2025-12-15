#!/bin/zsh
# @file .xinitrc
# @brief X11 initialization.

# --- 1. DISPLAY VARS ---
# @note These are useful for scripts called by DWM
export _HDMI=$(xrandr | grep -E '^HDMI[-0-9]* connected' | awk '{print $1}')
export _eDP=$(xrandr | grep -E '^eDP[-0-9]* connected' | awk '{print $1}')
export ROFI_PNG_OUTPUT=$HOME/Pictures/Rofi-Captures.jpg

# --- 2. SOURCE UTILS (Optional) ---
# @note Source shell_utils here ONLY if you need the COLOR variables 
# for scripts running in the background (like dwmblocks).
if [ -f "$HOME/.fus/shell_utils.sh" ]; then
    . "$HOME/.fus/shell_utils.sh"
fi

# --- 3. AUTOSTART ---
# @brief Executes background services.
if [ -f "$HOME/.fus/auto_start.sh" ]; then
    "$HOME/.fus/auto_start.sh" &
fi

# --- 4. START DWM ---
# @brief Starts the Window Manager. Must be the last line.
# exec dwm
exec dbus-launch --exit-with-session dwm

