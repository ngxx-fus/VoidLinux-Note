#!/bin/zsh

# @brief Load external shell utilities (colors, print_msg, yes_or_no)
source /home/fus/.fus/shell_utils.sh

# VARS #################################

# @var DEV_MODE
# @brief Execution mode: 1 for test (dry-run), 0 for execution
export DEV_MODE=0

# @var SOURCE_DIR
# @brief Root path of the system. Leave empty "" to select system Root (/)
SOURCE_DIR=

# @var TARGET_DIR
# @brief Destination folder for backup
TARGET_DIR="/home/fus/Downloads/Voidlinux-Note"

# BINs ################################
SUDO=/usr/bin/sudo
DIRNAME=/usr/bin/dirname

# @var BACKUP
# @brief List of files/directories to backup
BACKUP=(
    "home/fus/.fus"
    "home/fus/.zshrc"
    "usr/share/icons"
    "etc/sv/MyService0"
    "etc/sv/MyService1"
    "etc/dunst/dunstrc"
    "home/fus/.xinitrc"
    "home/fus/.display"
    "home/fus/.zprofile"
    "etc/X11/xorg.conf.d"
    "etc/acpi/handler.sh"
    "home/fus/.backup.sh"
    "home/fus/.config/nvim"
    "etc/elogind/logind.conf"
    "home/fus/.config/fcitx"
    "home/fus/.config/fcitx5"
    "home/fus/.ngxxfus.init.system.sh"
    "home/fus/.oh-my-zsh/themes/ngxxfus.zsh-theme"
)

# @var SOURCE_DIR_EXCLUDE
# @brief Files/Patterns to IGNORE when copying FROM Source TO Target
# @note These files will NOT be copied.
SOURCE_DIR_EXCLUDE=(
    "*.tmp"
    "*.log"
    "esp-idf"
    "node_modules"
    "__pycache__"
    ".cache"
    ".git" 
)

# @var TARGET_DIR_EXCLUDE
# @brief Files/Dirs ALREADY in TARGET_DIR to preserve during clean-up phase
# @note These files will NOT be deleted from backup folder.
TARGET_DIR_EXCLUDE=(
    ".git"
    "readme.md"
    ".gitmodules"
    ".gitignore"
)

# FUNCTIONS ###########################

# @fn copy_all
# @brief Copy source to destination using rsync with progress and EXCLUDES
# @param $1 Source path
# @param $2 Destination path
# @return 0 on success, 1 on error
copy_all(){
    if [[ $# -ne 2 ]]; then
        print_msg "${LRED}Error: copy_all requires exactly 2 arguments.${NORM}"
        return 1
    fi

    # Base rsync options
    # @note -a: archive mode, --delete: (optional) make dest exactly like source
    local RSYNC_OPTS="-a --info=progress2 --human-readable"

    # Append source excludes to rsync command
    for pattern in "${SOURCE_DIR_EXCLUDE[@]}"; do
        RSYNC_OPTS="$RSYNC_OPTS --exclude=$pattern"
    done

    print_msg "---> $SUDO rsync $RSYNC_OPTS -- $1 $2"
    
    if [ $DEV_MODE -eq 0 ]; then
        # Use $=VAR to allow zsh to split the string into arguments
        $SUDO rsync $=RSYNC_OPTS -- "$1" "$2"
    fi
}

# @fn is_target_exclude
# @brief Check if a filename is in the TARGET_DIR_EXCLUDE list
# @param $1 Filename to check
# @return 0 if found (true), 1 if not found (false)
is_target_exclude(){
    if [ $# -eq 1 ]; then
        for name in "${TARGET_DIR_EXCLUDE[@]}"; do 
            if [[ "$1" == "$name" ]]; then
                return 0
            fi
        done
    fi
    return 1
}

# INFOS ###############################
print_msg "${BOLD}${LGREEN}[INFO]${NORM}"
print_msg "${LYELLOW}Source: ${SOURCE_DIR:-/} | Target: $TARGET_DIR${NORM}"

# CLEANUP OLD FILES ###################
# @brief Check if target exists and ask to clean old files
if [ -e $TARGET_DIR ]; then
    print_msg "${LYELLOW}Do you want to clean old files in ${TARGET_DIR}? (Keeping TARGET_DIR_EXCLUDE)${NORM}"

    # @note If user says NO (return > 0), we skip cleanup
    yes_or_no

    if [ $? -gt 0 ]; then
        # @note Iterate through all files in Target Root
        # Zsh glob: * matches files, (D) includes dotfiles
        for file in "$TARGET_DIR"/*(D); do
            
            BASE=$(/usr/bin/basename $file)

            # @note Skip current and parent directory pointers
            [[ "$BASE" == "." || "$BASE" == ".." ]] && continue
            
            is_target_exclude $BASE 
            
            if [ $? -eq 0 ]; then
                print_msg "${LGREEN}KEEP${NORM} $file"
                continue
            else
                print_msg "${LRED}DELETE${NORM} $file"
                if [ $DEV_MODE -eq 0 ]; then
                    $SUDO rm -rf "$file"
                fi
            fi
        done
    fi
fi

# EXECUTION CONFIRMATION ##############
print_msg "${LYELLOW}Start Backup Process?${NORM}"

yes_or_no

if [ $? -gt 0 ]; then
    print_msg "${LRED}---> Exit!"
    exit 0
fi

# MAIN BACKUP LOOP ####################
for path in "${BACKUP[@]}"; do
    print_msg "${LYELLOW}Backup $path${NORM}"
    
    # @brief Get parent dir to replicate structure
    parent=$($DIRNAME $path)
    target_parent=$TARGET_DIR/$parent
    
    # @brief Check and create parent directory in target
    if [ -d $target_parent ]; then
        # print_msg "$target_parent exists"
        :
    else
        print_msg "$target_parent is not found"
        print_msg "---> $SUDO mkdir -p $target_parent"
        if [ $DEV_MODE -eq 0 ]; then
            $SUDO mkdir -p $target_parent
        fi
    fi
    
    # @brief Perform the copy
    # FIXED: Copy Source File into Target PARENT Dir to avoid nested duplication (.fus/.fus)
    copy_all "$SOURCE_DIR/$path" "$target_parent"
done

print_msg "${LGREEN}DONE!${NORM}"
