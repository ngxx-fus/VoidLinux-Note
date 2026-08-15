#!/bin/sh

: '/*
 * @file Install_Neovim.sh
 * @brief Automated downloader, prerequisite checker, and configuration setup script for Neovim.
 */'

# Include logging utilities using POSIX dot operator
. /home/fus/.fus/Utilities/SystemLog.sh

export GIT_PATH="/usr/bin/git"
export WGET_PATH="/usr/bin/wget"
export TAR_PATH="/usr/bin/tar"
export RM_PATH="/bin/rm"
export LN_PATH="/bin/ln"
export DIRNAME_PATH="/usr/bin/dirname"
export MAKE_PATH="/usr/bin/make"
export CMAKE_PATH="/usr/bin/cmake"
export GCC_PATH="/usr/bin/gcc"
export UNZIP_PATH="/usr/bin/unzip"
export CURL_PATH="/usr/bin/curl"

export NVIM_ZIP_VERSION="v0.12.4"
export NVIM_ZIP_FILENAME="nvim-linux-x86_64.tar.gz"
export NVIM_ZIP_URL="https://github.com/neovim/neovim/releases/download/${NVIM_ZIP_VERSION}/${NVIM_ZIP_FILENAME}"
export NVIM_INSTALL_PATH="/home/fus/.fus/Applications/NVIM/"
export NVIM_EXEC_LINKED_PATH="/usr/local/bin/nvim"
export NVIM_CONFIG_URL="https://github.com/ngxx-fus/neovim-conf"
export NVIM_CONFIG_PATH="/home/fus/.config/nvim"

SL_Entry "Neovim ${NVIM_ZIP_VERSION} installation and setup procedure initiated."

# Check if the wget binary exists and is executable
if [ ! -x "$WGET_PATH" ]; then
    SL_Exit 1 "Required binary '$WGET_PATH' is missing or not executable."
    
    # Abort script due to missing download dependency
    exit 1
fi

# Check if the tar binary exists and is executable
if [ ! -x "$TAR_PATH" ]; then
    SL_Exit 1 "Required binary '$TAR_PATH' is missing or not executable."
    
    # Abort script due to missing tar dependency
    exit 1
fi

# Check if the rm binary exists and is executable
if [ ! -x "$RM_PATH" ]; then
    SL_Exit 1 "Required binary '$RM_PATH' is missing or not executable."
    
    # Abort script due to missing rm dependency
    exit 1
fi

# Check if the ln binary exists and is executable
if [ ! -x "$LN_PATH" ]; then
    SL_Exit 1 "Required binary '$LN_PATH' is missing or not executable."
    
    # Abort script due to missing ln dependency
    exit 1
fi

# Check if the git binary exists and is executable
if [ ! -x "$GIT_PATH" ]; then
    SL_Exit 1 "Required binary '$GIT_PATH' is missing or not executable."
    
    # Abort script due to missing git dependency
    exit 1
fi

SL_Info "Verifying build and runtime prerequisites (gcc, make, cmake, unzip, curl)..."

# Verify essential compilation and extraction prerequisites
for tool_path in "$MAKE_PATH" "$CMAKE_PATH" "$GCC_PATH" "$UNZIP_PATH" "$CURL_PATH"; do
    if [ ! -x "$tool_path" ]; then
        SL_Info "Warning: Prerequisite '$tool_path' is missing or not executable. Ensure build dependencies are installed."
    fi
done

SL_Info "Downloading Neovim ${NVIM_ZIP_VERSION} [FILE=$NVIM_ZIP_FILENAME]"

# Execute download command via wget
"$WGET_PATH" -q --show-progress "$NVIM_ZIP_URL" -O "$NVIM_ZIP_FILENAME"
download_status=$?

# Evaluate the download status
if [ "$download_status" -ne 0 ]; then
    SL_Exit "$download_status" "Download failed from URL: $NVIM_ZIP_URL"
    
    # Abort execution on download failure
    exit "$download_status"
fi

SL_Info "Download completed successfully. Preparing target directory..."

# Check if the installation target directory exists
if [ ! -d "$NVIM_INSTALL_PATH" ]; then
    mkdir -p "$NVIM_INSTALL_PATH"
fi

SL_Info "Extracting $NVIM_ZIP_FILENAME to $NVIM_INSTALL_PATH..."

# Extract tarball contents into the installation directory
"$TAR_PATH" -xzf "$NVIM_ZIP_FILENAME" -C "$NVIM_INSTALL_PATH" --strip-components=1
extract_status=$?

# Evaluate the extraction status
if [ "$extract_status" -ne 0 ]; then
    SL_Exit "$extract_status" "Failed to extract archive '$NVIM_ZIP_FILENAME'."
    
    # Abort execution on extraction failure
    exit "$extract_status"
fi

SL_Info "Extraction successful. Removing archive file $NVIM_ZIP_FILENAME..."

# Clean up downloaded tar archive
"$RM_PATH" -f "$NVIM_ZIP_FILENAME"
rm_status=$?

# Evaluate the file cleanup status
if [ "$rm_status" -ne 0 ]; then
    SL_Exit "$rm_status" "Failed to remove archive file '$NVIM_ZIP_FILENAME'."
    
    # Abort execution on cleanup failure
    exit "$rm_status"
fi

SL_Info "Creating symbolic link at $NVIM_EXEC_LINKED_PATH..."

# Ensure target symlink parent directory exists
symlink_dir=$("$DIRNAME_PATH" "$NVIM_EXEC_LINKED_PATH")
if [ ! -d "$symlink_dir" ]; then
    mkdir -p "$symlink_dir"
fi

# Create or overwrite the symbolic link to the nvim executable
"$LN_PATH" -sf "${NVIM_INSTALL_PATH}/bin/nvim" "$NVIM_EXEC_LINKED_PATH"
link_status=$?

# Evaluate the symbolic link creation status
if [ "$link_status" -ne 0 ]; then
    SL_Exit "$link_status" "Failed to create symbolic link at '$NVIM_EXEC_LINKED_PATH'."
    
    # Abort execution on symlink creation failure
    exit "$link_status"
fi

SL_Info "Deploying Neovim configuration repository from $NVIM_CONFIG_URL..."

# Evaluate whether the configuration directory already exists
if [ -d "$NVIM_CONFIG_PATH/.git" ]; then
    SL_Info "Existing configuration repository found at $NVIM_CONFIG_PATH. Pulling latest changes..."
    
    # Fetch and pull latest configuration updates
    "$GIT_PATH" -C "$NVIM_CONFIG_PATH" pull
    git_status=$?
else
    SL_Info "Cloning configuration into $NVIM_CONFIG_PATH..."
    
    # Ensure parent directory of configuration exists
    config_parent_dir=$("$DIRNAME_PATH" "$NVIM_CONFIG_PATH")
    if [ ! -d "$config_parent_dir" ]; then
        mkdir -p "$config_parent_dir"
    fi
    
    # Clone the configuration repository
    "$GIT_PATH" clone "$NVIM_CONFIG_URL" "$NVIM_CONFIG_PATH"
    git_status=$?
fi

# Evaluate the git clone or pull status
if [ "$git_status" -ne 0 ]; then
    SL_Exit "$git_status" "Failed to set up Neovim configuration repository."
    
    # Abort execution on git operation failure
    exit "$git_status"
fi

SL_Info "Successfully installed Neovim ${NVIM_ZIP_VERSION}, linked binary, and configured repository."
SL_Exit 0 "Neovim setup completed successfully."

# Terminate script with success code
exit 0