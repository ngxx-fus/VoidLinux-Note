#!/bin/zsh 
# @file global_vars.sh
# @brief System-wide environment variables.

source ./user_aliases.sh
source ./shell_utils.sh

export BROWSER=firefox
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Fcitx configuration
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

# Path additions (IDF, local bin)
export IDF_PATH=/home/fus/.fus/esp-idf/
export PATH=$PATH:/home/fus/.fus/
export PATH=$PATH:/home/fus/.fus/esp-idf/
export PATH=$PATH:$HOME/.local/bin


