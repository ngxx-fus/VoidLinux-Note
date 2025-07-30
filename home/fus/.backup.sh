#!/bin/zsh

source /home/fus/.fus/shell_utils.sh
# VARS #################################
# DEV_MODE: 1 - test; 0 - exec
export DEV_MODE=0
SOURCE_DIR=
HOME_DIR=/home/fus
TARGET_DIR=/mnt/SD
# BINs ################################
SUDO=/usr/bin/sudo
DIRNAME=/usr/bin/dirname

# NOTE: Backup paths must start without leading slash (i.e., relative to root)
# Because if SOURCE_DIR="" (empty), then "$SOURCE_DIR/$path" becomes "/home/fus/..."
# The slash before $path ensures it's treated as an absolute path from root.
BACKUP=(
  "home/fus/.fus"
  "home/fus/.zshrc"
  "usr/share/fonts"
  "home/fus/.display"
  "home/fus/.backup.sh"
  "etc/acpi/handler.sh"
  "home/fus/.config/nvim"
)

# FUNCTIONS ###########################

copy_all(){
    # only accept TWO params
    if [[ $# -ne 2 ]]; then
        print_msg "${LRED}Error: copy_all requires exactly 2 arguments.${NORM}"
        return 1
    fi

    print_msg "---> $SUDO cp -vrf -- $1 $2$"
    if [ $DEV_MODE -eq 0 ]; then
        $SUDO cp -vrf $1 $2
    fi
}

# INFOS ###############################
print_msg "${BOLD}${LGREEN}[INFO]${NORM}"
print_msg "${LYELLOW}This script will copy dir or file in backup paths from local-root=SOURCE_DIR to \
a backup-root=TARGET_DIR, the structure will be preserve.${NORM}"
print_msg "${GRAY}(If \$SOURCE is empty, it's set at root by default!)${NORM}"
print_msg "${LYELLOW}SOURCE   =   $SOURCE_DIR${NORM}"
print_msg "${LYELLOW}DEST     =   $TARGET_DIR${NORM}"
print_msg "Backup paths:"

for path in "${BACKUP[@]}"; do
    print_msg "\t$SOURCE_DIR/$path"
done

# print_msg "Backup paths:"

print_msg "${LYELLOW}Do you want to keep all old files in ${TARGET_DIR}?${NORM}"

yes_or_no

if [ $? -gt 0 ]; then
    print_msg "$SUDO rm -vrf ${TARGET_DIR}/*"
    $SUDO rm -vrf ${TARGET_DIR}/*
fi

print_msg "${LYELLOW}Do you want to continue?${NORM}"

yes_or_no

if [ $? -gt 0 ]; then
    print_msg "${LRED}---> Exit!"
    exit 0
fi


for path in "${BACKUP[@]}"; do
    print_msg "${LYELLOW}Backup $path${NORM}"
    parent=$($DIRNAME $path)
    target_parent=$TARGET_DIR/$parent
    if [ -d $target_parent ]; then
        print_msg "$target_parent is exited"
    else
        print_msg "$target_parent is not found"
        print_msg "---> $SUDO mkdir -p $target_parent"
        if [ $DEV_MODE -eq 0 ]; then
            $SUDO mkdir -p $target_parent
        fi
    fi
    copy_all $SOURCE_DIR/$path $TARGET_DIR/$path
done
