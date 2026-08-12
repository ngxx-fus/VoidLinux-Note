#!/bin/sh

###############################################################################
# SystemLog utils 
# This script provides logging to both the terminal and a log file.
#   + Terminal logging uses `printf` to format the output.
#   + File logging uses `>>` to append data.
# To use this script, you need to use the `source` keyword.
###############################################################################

###############################################################################
# GUARD CHECK | BEGIN #########################################################

# Do not export this variable so it remains local to the current shell session
if [ "${SL_LOG_TERMINAL_INITIALIZED:-0}" -ne 0 ]; then 
    # Halt execution to prevent re-defining functions in the same shell
    return 0 2>/dev/null || exit 0
fi

# Use standard variable instead of 'export'
SL_LOG_TERMINAL_INITIALIZED=1

# GUARD CHECK | END ###########################################################
###############################################################################

###############################################################################
# TEXT EFFECTS | BEGIN ########################################################
# To use the text effects below, insert the code to apply the text style. 
#   E.g: printf "${BOLD}${LRED}This is a bolded-red line!${NORM}\n"
# NOTE:
#   - `L`   prefix stands for "light", the color will be paler.
#   - `BG_` prefix stands for "background", applies to the background.

export BOLD="\033[1m"
export FAINT="\033[2m"
export ITALIC="\033[3m"
export UNDERLINED="\033[4m"
export BLACK="\033[30m"
export RED="\033[31m"
export GREEN="\033[32m"
export YELLOW="\033[33m"
export BLUE="\033[34m"
export MAGENTA="\033[35m"
export CYAN="\033[36m"
export LGRAY="\033[37m"
export GRAY="\033[90m"
export LRED="\033[91m"
export LGREEN="\033[92m"
export LYELLOW="\033[93m"
export LBLUE="\033[94m"
export LMAGENTA="\033[95m"
export LCYAN="\033[96m"
export WHITE="\033[97m"
export BG_BLACK="\033[40m"
export BG_RED="\033[41m"
export BG_GREEN="\033[42m"
export BG_YELLOW="\033[43m"
export BG_BLUE="\033[44m"
export BG_MAGENTA="\033[45m"
export BG_CYAN="\033[46m"
export BG_LGRAY="\033[47m"
export BG_GRAY="\033[100m"
export BG_LRED="\033[101m"
export BG_LGREEN="\033[102m"
export BG_LYELLOW="\033[103m"
export BG_LBLUE="\033[104m"
export BG_LMAGENTA="\033[105m"
export BG_LCYAN="\033[106m"
export BG_WHITE="\033[107m"
export NORM="\033[0m"
export RESET="\033[0m"

# TEXT EFFECTS | END ##########################################################
###############################################################################

###############################################################################
# SYSTEM LOG | BEGIN ##########################################################

export SL_LOG_PATH="/tmp/SystemLog.log"
export SL_DATE_PATH="/usr/bin/date"
export SL_TEE_PATH="/usr/bin/tee"
export SL_PRINTF_PATH="/usr/bin/printf"
export SL_DIRNAME_PATH="/usr/bin/dirname"

: '/*
 * @brief Resets the log file, validates required binaries, and creates the host directory.
 */'
SL_Init() {
    # Check if all required binaries are executable
    if [ ! -x "$SL_DATE_PATH" ] || [ ! -x "$SL_TEE_PATH" ] || [ ! -x "$SL_PRINTF_PATH" ] || [ ! -x "$SL_DIRNAME_PATH" ]; then
        echo "Error: One or more required SystemLog binaries are missing or not executable."
        # Abort initialization due to missing binaries
        return 1
    fi

    local dir_path
    dir_path=$("$SL_DIRNAME_PATH" "$SL_LOG_PATH")
    
    # Check if the target log directory exists
    if [ ! -d "$dir_path" ]; then
        mkdir -p "$dir_path"
    fi
    
    echo "" > "$SL_LOG_PATH"
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Logs an entry event with a timestamp.
 * @param $1 The message to be logged.
 */'
SL_Entry() {
    local time_str
    time_str=$("$SL_DATE_PATH" "+[%Y/%m/%d - %H:%M:%S.%3N]")
    
    "$SL_PRINTF_PATH" "%s[>>>] %s\n" "$time_str" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Logs an exit event with an optional return code and a timestamp.
 * @param $1 The return code (if two arguments are passed), else the message.
 * @param $2 The message to be logged (if return code is provided).
 */'
SL_Exit() {
    local time_str
    time_str=$("$SL_DATE_PATH" "+[%Y/%m/%d - %H:%M:%S.%3N]")
    
    # Check the argument count to determine formatting
    if [ "$#" -eq 2 ]; then
        "$SL_PRINTF_PATH" "%s[<<<][CODE=%s] %s\n" "$time_str" "$1" "$2" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    else
        "$SL_PRINTF_PATH" "%s[<<<] %s\n" "$time_str" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    fi
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Logs an informational message with a timestamp.
 * @param $1 The message to be logged.
 */'
SL_Info() {
    local time_str
    time_str=$("$SL_DATE_PATH" "+[%Y/%m/%d - %H:%M:%S.%3N]")
    
    "$SL_PRINTF_PATH" "%s[INFO] %s\n" "$time_str" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Prints a standard log message with a timestamp.
 * @param $1 The message to be logged.
 */'
SL_Print() {
    local time_str
    time_str=$("$SL_DATE_PATH" "+[%Y/%m/%d - %H:%M:%S.%3N]")
    
    "$SL_PRINTF_PATH" "%s %s\n" "$time_str" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Prints a raw message continuously without trailing or leading newlines.
 * @param $1 The message to be logged.
 */'
SL_ContinuousPrint() {
    "$SL_PRINTF_PATH" "%s\n" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    
    # Exit function successfully
    return 0
}

: '/*
 * @brief Checks whether a given file or resource exists on the system.
 * @param $1 The absolute or relative path to the file/resource.
 * @return 0 if the path exists, 1 otherwise.
 */'
SL_Exists() {
    # Evaluate if the specified path exists as a valid file or directory
    if [ -e "$1" ]; then
        # Path exists on host system
        return 0
    fi

    # Path does not exist on host system
    return 1
}

: '/*
 * @brief Logs an error message with an optional error code and timestamp.
 * @param $1 The error code (if two arguments are passed), else the message.
 * @param $2 The message to be logged (if error code is provided).
 */'
SL_Error() {
    local time_str
    time_str=$("$SL_DATE_PATH" "+[%Y/%m/%d - %H:%M:%S.%3N]")
    
    # Check the argument count to determine formatting
    if [ "$#" -eq 2 ]; then
        "$SL_PRINTF_PATH" "%s[ERROR][CODE=%s] %s\n" "$time_str" "$1" "$2" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    else
        "$SL_PRINTF_PATH" "%s[ERROR] %s\n" "$time_str" "$1" | "$SL_TEE_PATH" -a "$SL_LOG_PATH"
    fi
    
    # Exit function successfully
    return 0
}

# EXEC INIT ###################################################################

# Initialize SystemLog safely upon sourcing
SL_Init || return 1 2>/dev/null || exit 1

# SYSTEM LOG | END ############################################################
###############################################################################