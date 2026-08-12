#!/bin/sh
 
###################################################################################################
# GLOBAL VAR(S) & FUNC(S) #########################################################################        

# Return code ref:
#       SUCCESS: 0x0
#       ERROR  : 0x1

PATH_GLOABL_LOG="/tmp/Init.log"
ScriptInit_RootDir="/home/fus/.fus/"

ScriptInit_Info() {
    echo "[$(date "+%H:%M:%S")][USERINIT_CLI][INFO] $@"
}

ScriptInit_Error() {
    echo "[$(date "+%H:%M:%S")][USERINIT_CLI][ERROR] $@"
}

ScriptInit_IsExisted() {
    # Check if the file or directory exists
    if [ -e "$1" ]; then
        return 0
    else
        return 1
    fi
}

ScriptInit_Mkdir() {
    # Make dir if not existed
    if ! ScriptInit_IsExisted "$1"; then
        ScriptInit_Info "Creating directory: $1"
        mkdir -p "$1"
    else
        ScriptInit_Info "Directory already exists: $1"
    fi
}

ScriptInit_Result() {
    local exit_code=$?
    if [[ ${exit_code} -eq 0 ]]; then
        echo "[$(date "+%H:%M:%S")][USERINIT_CLI][INFO] SUCCESS"
        echo "[$(date "+%H:%M:%S")][USERINIT_CLI][INFO] SUCCESS" >> $PATH_GLOABL_LOG
    else
        echo "[$(date "+%H:%M:%S")][USERINIT_CLI][INFO] ERROR: CODE=${exit_code}"
        echo "[$(date "+%H:%M:%S")][USERINIT_CLI][INFO] ERROR: CODE=${exit_code}" >> $PATH_GLOABL_LOG
    fi
}


###################################################################################################
# ADD USER ALIASES ################################################################################        

if ScriptInit_IsExisted "$ScriptInit_RootDir/Utilities/UserAlias.sh"; then
    ScriptInit_Info "> Fetching [UserAlias.sh] ..."
    . "$ScriptInit_RootDir/Utilities/UserAlias.sh"
    ScriptInit_Result
else
    ScriptInit_Error "> Skip [Fetching UserAlias.sh]! ERROR: file not found!"
fi

###################################################################################################
# ADD USER SHELL UTILS ############################################################################        

if ScriptInit_IsExisted "$ScriptInit_RootDir/Utilities/ShellUtils.sh"; then
    ScriptInit_Info "> Fetching [ShellUtils.sh] ..."
    . "$ScriptInit_RootDir/Utilities/ShellUtils.sh"
    ScriptInit_Result
else
    ScriptInit_Error "> Skip [Fetching ShellUtils.sh]! ERROR: file not found!"
fi

###################################################################################################
# ADD USER PATH(S) ################################################################################        
# Check if the Neovim executable exists before adding it to PATH
if ScriptInit_IsExisted "$ScriptInit_RootDir/Applications/nvim/bin/nvim"; then
    ScriptInit_Info "> Adding [nvim] into system PATH..."
    export PATH="$PATH:$ScriptInit_RootDir/Applications/nvim/bin/"
    ScriptInit_Result
else
    ScriptInit_Error "> Skip [Adding nvim PATH]! ERROR: file not found!"
fi
###################################################################################################

