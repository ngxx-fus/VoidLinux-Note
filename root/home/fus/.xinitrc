#!/bin/sh
# ==============================================================================
# ~/.xinitrc
# Void Linux X11 session initialization for BSPWM
# ==============================================================================

# Merge Xresources and keymaps if present
[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"
[ -f "$HOME/.Xmodmap" ] && xmodmap "$HOME/.Xmodmap"

# Source system Xinit scripts if present
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# Set default cursor shape so X11 does not show legacy 'X' cursor
xsetroot -cursor_name left_ptr &

# Input method environment variables (Fcitx5)
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export MOZ_USE_XINPUT2=1

# Launch BSPWM inside a DBus session if not already active
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ] && command -v dbus-run-session >/dev/null 2>&1; then
    exec dbus-run-session bspwm
else
    exec bspwm
fi

