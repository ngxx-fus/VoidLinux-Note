#!/bin/sh

###################################################################################################
# SYSTEM LOG ######################################################################################        

. /home/fus/.fus/Utilities/SystemLog.sh

SL_Entry "UserInit_CLI.sh"

###################################################################################################
# ADD USER ALIASES ################################################################################        
ScriptInit_RootDir="/home/fus/.fus"

if SL_Exists "$ScriptInit_RootDir/Utilities/UserAlias.sh"; then
    SL_Info "Sourcing UserAlias.sh"
    . "$ScriptInit_RootDir/Utilities/UserAlias.sh"
else
    SL_Error 1 "UserAlias.sh not found!"
fi

###################################################################################################

SL_Exit "UserInit_CLI.sh"
