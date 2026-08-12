#!/bin/sh
 
###################################################################################################
# GLOBAL VAR(S) & FUNC(S) #########################################################################        

# Return code ref:
#       SUCCESS: 0x0
#       ERROR  : 0x1

PATH_GLOABL_LOG="/tmp/Init.log"
AutoStartCLI_RootDir="/home/fus/.fus/"

AutoStartCLI_Info() {
    echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] $@"
    echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] $@" >> $PATH_GLOABL_LOG
}

AutoStartCLI_Result() {
    local exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] SUCCESS"
        echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] SUCCESS" >> $PATH_GLOABL_LOG
    else
        echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] ERROR: CODE=${exit_code}"
        echo "[$(date "+%H:%M:%S")][AUTOSTART_CLI][INFO] ERROR: CODE=${exit_code}" >> $PATH_GLOABL_LOG
    fi
}

###################################################################################################
# INIT GLOBAL VARS $$$$############################################################################        

AutoStartCLI_Info "> Fetching [GlobalVars.sh] ..."
. "/home/fus/.fus/Utilities/GlobalVars.sh"
AutoStartCLI_Result

exec /home/fus/.fus/Applications/FireBrowserQuantum/filebrowser -c /home/fus/.fus/Applications/FireBrowserQuantum/config.yaml >> /home/fus/.fus/Applications/FireBrowserQuantum/FileBrowser.log & 
