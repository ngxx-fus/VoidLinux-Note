#!/bin/zsh

export _fus="/home/fus/.fus"
source $_fus/text_effects

while true; do
    DATETIME=" [ ${LBLUE} $(date '+%d:%m:%Y %H:%M:%S') ] ${NORM}"
    xsetroot -name "${DATETIME}"    
    sleep 1
done
