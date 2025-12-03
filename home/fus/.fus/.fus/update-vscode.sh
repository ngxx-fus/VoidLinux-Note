#!/bin/zsh
set -e

# Directory where VS Code parent folder exists
INSTALL_DIR="/opt/vscode"
# VS Code uses .tar.gz, not .tar.xz
TMP_TAR="/tmp/vscode-linux-x64.tar.gz"
# This URL redirects to the latest stable .tar.gz for Linux x64
URL="https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"

# If you want the 'Insiders' (Nightly) version, uncomment the line below:
# URL="https://code.visualstudio.com/sha/download?build=insider&os=linux-x64"

echo "[*] Updating VS Code..."

sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "1 Downloading latest build..."
# Added -L to follow redirects (Microsoft uses redirects for downloads)
sudo wget --verbose -L -O "$TMP_TAR" "$URL"

echo "2 Removing old version..."
# The VS Code tarball extracts to a folder named 'VSCode-linux-x64'
sudo rm -rf "$INSTALL_DIR/VSCode-linux-x64"

echo "3 Extracting..."
# Changed -xJf (xz) to -xzf (gzip)
sudo tar -xzf "$TMP_TAR" -C "$INSTALL_DIR"

echo "4 Cleaning up..."
sudo rm -f "$TMP_TAR"

echo "> VS Code updated successfully!"
