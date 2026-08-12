#!/bin/zsh
 
###################################################################################################
# GLOBAL VAR(S) & FUNC(S) #########################################################################        

# Return code ref:
#       SUCCESS: 0x0
#       ERROR  : 0x1

PATH_GLOABL_LOG="/tmp/Init.log"
AutoStartGUI_RootDir="/home/fus/.fus/"

AutoStartGUI_Info() {
    echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] $@"
    echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] $@" >> $PATH_GLOABL_LOG
}

AutoStartGUI_Result() {
    local exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] SUCCESS"
        echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] SUCCESS" >> $PATH_GLOABL_LOG
    else
        echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] ERROR: CODE=${exit_code}"
        echo "[$(date "+%H:%M:%S")][AUTOSTART_GUI][INFO] ERROR: CODE=${exit_code}" >> $PATH_GLOABL_LOG
    fi
}

###################################################################################################
# ADD USER ALIASES ################################################################################        

AutoStartGUI_Info "> Fetching [GlobalVars.sh] ..."
source /home/fus/.fus/Utilities/GlobalVars.sh
AutoStartGUI_Result

###################################################################################################
# DWM-BLOCKS ######################################################################################

AutoStartGUI_Info "> Starting [dwmblocks] ..."
exec /usr/local/bin/dwmblocks >> "${PATH_GLOABL_LOG}" 2>&1 &
AutoStartGUI_Result

###################################################################################################
# copyq ###########################################################################################

AutoStartGUI_Info "> Starting [copyq] ..."
exec /usr/bin/copyq >> "${PATH_GLOABL_LOG}" 2>&1 &
AutoStartGUI_Result

###################################################################################################
# SET BACKGROUND ##################################################################################

AutoStartGUI_Info "> Starting [SetupBackgroun.sh] ..."
exec /home/fus/.fus/Utilities/SetupBackgroun.sh >> "${PATH_GLOABL_LOG}" 2>&1 &
AutoStartGUI_Result

###################################################################################################
# SET FCITX #######################################################################################

AutoStartGUI_Info "> Starting [fcitx5] ..."
exec /usr/bin/fcitx5 >> "${PATH_GLOABL_LOG}" 2>&1 &
AutoStartGUI_Result

###################################################################################################
# START PICOM #####################################################################################

AutoStartGUI_Info "> Starting [picom] ..."
exec /usr/bin/picom --backend xrender >> "${PATH_GLOABL_LOG}" 2>&1 &
AutoStartGUI_Result



###################################################################################################
# INIT GLOBAL VARS $$$$############################################################################

exec /home/fus/.fus/Applications/FireBrowserQuantum/filebrowser -c /home/fus/.fus/Applications/FireBrowserQuantum/config.yaml >> /home/fus/.fus/Applications/FireBrowserQuantum/FileBrowser.log 2>&1 &

