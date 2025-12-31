#!/bin/zsh
set -e

INSTALL_DIR="/opt/firefox-nightly"
TMP_TAR="/tmp/firefox.en-US.linux-x86_64.tar.xz"
URL="https://download.mozilla.org/?product=firefox-nightly-latest-ssl&os=linux64&lang=en-US"

echo "[*] Updating Firefox Nightly..."

sudo mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

echo "1 Downloading latest build..."
sudo wget -q --content-disposition --trust-server-names -O "$TMP_TAR" "$URL"

echo "2 Removing old version..."
sudo rm -rf "$INSTALL_DIR/firefox"

echo "3 Extracting..."
sudo tar -xJf "$TMP_TAR" -C "$INSTALL_DIR"

echo "4 Cleaning up..."
sudo rm -f "$TMP_TAR"

echo "> Firefox Nightly updated successfully!"

