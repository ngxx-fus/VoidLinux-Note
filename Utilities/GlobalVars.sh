#!/bin/zsh 

export BROWSER=firefox
export XDG_RUNTIME_DIR=/run/user/$(id -u)

# Fcitx configuration
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

export IDF_PATH="$HOME/.fus/esp-idf"
