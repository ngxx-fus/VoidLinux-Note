#!/bin/zsh
set -e

#/// Directory where VS Code parent folder exists
INSTALL_DIR="/usr/share"

#/// Temporary path for the downloaded tarball
TMP_TAR="/tmp/vscode-linux-x64.tar.gz"

#/// Temporary directory to verify extraction before installing
TMP_EXTRACT_DIR="/tmp/vscode-update-safe-extract"

#/// URL redirects to the latest stable .tar.gz for Linux x64
URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"

echo "[*] Updating VS Code..."

#/// Create installation directory if it does not exist
sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "1. Downloading latest build..."
#/// Download the file following redirects (-L) and show progress bar
sudo wget --show-progress -q -L -O "$TMP_TAR" "$URL"

# ---------------------------------------------------------
# PRINT INFO SECTION
# ---------------------------------------------------------
echo "\n[INFO] Downloaded Artifact Details:"
if [[ -f "$TMP_TAR" ]]; then
    #/// Print file size in human-readable format
    SIZE=$(du -h "$TMP_TAR" | cut -f1)
    echo "   -> File: $TMP_TAR"
    echo "   -> Size: $SIZE"
    #/// Print file type to ensure it is a valid gzip archive
    echo "   -> Type: $(file -b "$TMP_TAR")"
    
    #/// Verify if the file size is greater than 0
    if [[ ! -s "$TMP_TAR" ]]; then
        echo "[ERROR] File is empty. Aborting installation."
        exit 1
    fi
else
    echo "[ERROR] Download failed. File not found."
    exit 1
fi
echo "---------------------------------------------------------\n"

echo "2. Safety Check: Extracting to temporary location..."
#/// Clean up previous extraction attempts if any
rm -rf "$TMP_EXTRACT_DIR"
mkdir -p "$TMP_EXTRACT_DIR"

#/// Extract to temp first to verify archive integrity
#/// If this fails, the script exits (set -e) and the old version remains untouched
tar -xzf "$TMP_TAR" -C "$TMP_EXTRACT_DIR"

echo "   -> Extraction verification successful."

# ---------------------------------------------------------
# USER CONFIRMATION
# ---------------------------------------------------------
echo "\n[CONFIRMATION REQUIRED]"
echo "   -> Target Install Path: $INSTALL_DIR/VSCode"
echo -n "   -> Do you want to remove the old version and install the new one? (y/n): "
read -r response

if [[ "$response" =~ ^[yY]$ ]]; then
    echo "\n3. Installing..."
    
    #/// Remove the existing VS Code directory
    echo "   -> Removing old version..."
    sudo rm -rf "$INSTALL_DIR/VSCode"

    #/// Move the verified extracted folder to the install directory
    echo "   -> Moving new version to installation directory..."
    # The tarball contains a folder named 'VSCode' inside it
    sudo cp -vrf "$TMP_EXTRACT_DIR/VSCode-linux-x64" "$INSTALL_DIR/VSCode"

    echo "> VS Code updated successfully!"
else
    echo "\n[CANCELLED] Installation aborted by user."
    echo "   -> The old version was NOT modified."
fi

echo "4. Cleaning up temporary files..."
#/// Remove the temporary tarball and extraction directory
sudo rm -f "$TMP_TAR"
rm -rf "$TMP_EXTRACT_DIR"

echo "Done."

