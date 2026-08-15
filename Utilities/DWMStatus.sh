#!/bin/zsh

while true; do
    DATETIME=" [ $(date '+%d:%m:%Y %H:%M:%S') ]"
    xsetroot -name "${DATETIME}"    
    sleep 1
done
