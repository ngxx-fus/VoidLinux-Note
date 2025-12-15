# @file .zprofile
# @brief Login shell configuration.

# 1. Load Global Variables FIRST
if [ -f "$HOME/.fus/global_vars.sh" ]; then
    printf "> source /home/fus/.fus/global_vars.sh\n"
    source "$HOME/.fus/global_vars.sh"
fi

# 2. Check login context and start X11
if [[ -z $SSH_CONNECTION && -z $DISPLAY && $XDG_VTNR -eq 1 ]]; then
    echo ""
    echo "[local-login] Starting dwm via startx... (after 1s)"
    sleep 1
    exec startx
else
    echo ""
    echo "[ssh-login] Logged in via SSH or already in X session."
fi

