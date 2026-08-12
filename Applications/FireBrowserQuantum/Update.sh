#!/bin/sh

: '/*
 * @file Install_FireBrowserQuantum.sh
 * @brief Automated downloader and updater script for FireBrowserQuantum binary release.
 */'

# Include logging utilities using POSIX dot operator
. ../../Utilities/SystemLog.sh

export WGET_PATH="/usr/bin/wget"
export EXEC_VERSION="v2.0.0-beta"
export EXEC_FILENAME="linux-amd64-filebrowser"
export EXEC_URL="https://github.com/gtsteffaniak/filebrowser/releases/download/${EXEC_VERSION}/${EXEC_FILENAME}"
export TARGET_EXEC_NAME="filebrowser"

SL_Entry "FireBrowserQuantum installation procedure initiated."

# Check if the wget binary exists and is executable
if [ ! -x "$WGET_PATH" ]; then
    SL_Exit 1 "Required binary '$WGET_PATH' is missing or not executable."
    
    # Abort script due to missing download dependency
    exit 1
fi

SL_Info "Downloading FireBrowserQuantum [VERSION=$EXEC_VERSION, EXEC=$EXEC_FILENAME]"

# Execute download command via wget
"$WGET_PATH" -q --show-progress "$EXEC_URL" -O "$EXEC_FILENAME"
download_status=$?

# Evaluate the download status
if [ "$download_status" -ne 0 ]; then
    SL_Exit "$download_status" "Download failed from URL: $EXEC_URL"
    
    # Abort execution on download failure
    exit "$download_status"
fi

SL_Info "Download completed successfully. Replacing old executable..."

# Grant execution rights to the downloaded file
chmod +x "$EXEC_FILENAME"

# Replace old executable file atomically
mv -f "$EXEC_FILENAME" "$TARGET_EXEC_NAME"
move_status=$?

# Evaluate the target file replacement result
if [ "$move_status" -ne 0 ]; then
    SL_Exit "$move_status" "Failed to replace target executable '$TARGET_EXEC_NAME'."
    
    # Abort execution on file move failure
    exit "$move_status"
fi

SL_Info "Successfully replaced '$TARGET_EXEC_NAME' with version $EXEC_VERSION."
SL_Exit 0 "FireBrowserQuantum update completed."

# Terminate script with success code
exit 0