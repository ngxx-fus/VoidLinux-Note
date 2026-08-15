#!/bin/zsh
 
###################################################################################################
# SYSTEM LOG ######################################################################################        

source /home/fus/.fus/Utilities/SystemLog.sh

echo "[DEBUG] PATH_GLOBAL_LOG=$PATH_GLOBAL_LOG"
echo "[DEBUG] PATH_GLOBAL_LOG=$PATH_GLOBAL_LOG" >> $PATH_GLOBAL_LOG

SL_Entry "AutoStart_GUI.sh"

###################################################################################################
# ADD USER ALIASES ################################################################################        

SL_Info "Fetching [GlobalVars.sh] ..."
. /home/fus/.fus/Utilities/GlobalVars.sh

###################################################################################################
# SET-UP DISPLAY ##################################################################################

SL_Info "Detecting and setting up displays ..."

HDMI1_STATE=$(xrandr | grep -c "^HDMI-1 connected")
HDMI2_STATE=$(xrandr | grep -c "^HDMI-2 connected")

# Check if both HDMI-1 and HDMI-2 are connected
if [ "$HDMI1_STATE" -eq 1 ] && [ "$HDMI2_STATE" -eq 1 ]; then
    SL_Info "Display: HDMI-1 & HDMI-2 connected (1 on 2)"
    xrandr --output HDMI-1 --auto --primary --output HDMI-2 --auto --below HDMI-1 >> "${PATH_GLOBAL_LOG}" 2>&1
# Check if only HDMI-1 is connected
elif [ "$HDMI1_STATE" -eq 1 ]; then
    SL_Info "Display: Only HDMI-1 connected"
    xrandr --output HDMI-1 --auto --primary --output HDMI-2 --off >> "${PATH_GLOBAL_LOG}" 2>&1
# Check if only HDMI-2 is connected
elif [ "$HDMI2_STATE" -eq 1 ]; then
    SL_Info "Display: Only HDMI-2 connected"
    xrandr --output HDMI-2 --auto --primary --output HDMI-1 --off >> "${PATH_GLOBAL_LOG}" 2>&1
# Handle fallback case when no displays are connected
else
    SL_Info "Display: No display detected. Headless mode (SSH)."
fi

###################################################################################################
# DWM-BLOCKS ######################################################################################

SL_Info "Starting [dwmblocks] ..."
/usr/local/bin/dwmblocks >> "${PATH_GLOBAL_LOG}" 2>&1 &

###################################################################################################
# copyq ###########################################################################################

SL_Info "Starting [copyq] ..."
/usr/bin/copyq >> "${PATH_GLOBAL_LOG}" 2>&1 &

###################################################################################################
# SET BACKGROUND ##################################################################################

SL_Info "Starting [SetupBackgroun.sh] ..."
/home/fus/.fus/Utilities/SetupBackgroun.sh >> "${PATH_GLOBAL_LOG}" 2>&1 &

###################################################################################################
# SET FCITX #######################################################################################

# SL_Info "Starting [fcitx5] ..."
# /usr/bin/fcitx5 >> "${PATH_GLOBAL_LOG}" 2>&1 &

SL_Info "Starting [fcitx5] ..."
eval $(dbus-launch --sh-syntax)
fcitx5 -d >> "/tmp/fcitx5.log" 2>&1

###################################################################################################
# SET X-CLIPBOARD-CAPTURE #########################################################################

SL_Info "Starting [fcitx5] ..."
/usr/bin/xClipBoardCapture >> "/tmp/xClipBoardCapture.log" 2>&1 & 

###################################################################################################
# START PICOM #####################################################################################

SL_Info "Starting [picom] ..."
/usr/bin/picom --backend xrender >> "${PATH_GLOBAL_LOG}" 2>&1 &
