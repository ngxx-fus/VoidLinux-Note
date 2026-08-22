###################################################################################################
# SYSTEM LOG ######################################################################################        

. /home/fus/.fus/Utilities/SystemLog.sh

SL_Entry ".xinitrc"

###################################################################################################
# SOURCING AUTOSTART-GUI ##########################################################################

if [ -f "/home/fus/.fus/AutoStart_GUI.sh" ]; then
    SL_Info "Sourcing [AutoStart_GUI.sh]..."
    .  "/home/fus/.fus/AutoStart_GUI.sh"
else
    SL_Error "Not found AutoStart_GUI.sh! Skipped!"
fi

###################################################################################################
# SOURCING USERINIT-GUI ###########################################################################

if [ -f "/home/fus/.fus/UserInit_GUI.sh" ]; then
    SL_Info "Sourcing [UserInit_GUI.sh]"
    .  "/home/fus/.fus/UserInit_GUI.sh"
else
    SL_Error "Not found UserInit_GUI.sh! Skipped!"
fi

###################################################################################################
# SET-UP DISPLAY ##################################################################################

# Migrate to /home/fus/.fus/Utilities/ToggleDisplay.sh
/home/fus/.fus/Utilities/ToggleDisplay.sh

###################################################################################################
# START-DWM #######################################################################################
exec dwm 
