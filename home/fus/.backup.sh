#!/bin/zsh

source /home/fus/.fus/shell_utils.sh
# VARS #################################
# DEV_MODE: 1 - test; 0 - exec
export DEV_MODE=0
SOURCE_DIR=
HOME_DIR=/home/fus
TARGET_DIR=/mnt/ExtSSD/VoidBackup
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
    "etc/sv/MyService0"
    "etc/sv/MyService1"
    "etc/dunst/dunstrc"
    "home/fus/.xinitrc"
    "home/fus/.display"
    "etc/acpi/handler.sh"
    "home/fus/.backup.sh"
    "home/fus/.config/nvim"
    "home/fus/.config/fcitx"
    "home/fus/.config/fcitx5"
)

EXCLUDE=(
    ".git"
    "readme.md"
)

# FUNCTIONS ###########################

copy_all(){
    # only accept TWO params
    if [[ $# -ne 2 ]]; then
        print_msg "${LRED}Error: copy_all requires exactly 2 arguments.${NORM}"
        return 1
    fi

    print_msg "---> $SUDO cp -rf -- $1 $2"
    if [ $DEV_MODE -eq 0 ]; then
        $SUDO cp -rf $1 $2
    fi
}

is_exclude(){
    if [ $# -eq 1 ]; then
        for name in "${EXCLUDE[@]}"; do 
            if [[ "$1" == "$name" ]]; then
                return 0
            fi
        done
    fi
    return 1
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

print_msg "Exclude filenames (in DESTINATION):"

for path in "${EXCLUDE[@]}"; do
    print_msg "\t$path"
done



# print_msg "Backup paths:"
if [ -e $TARGET_DIR ]; then
    print_msg "${LYELLOW}Do you want to keep all old files in ${TARGET_DIR}?${NORM}"

    yes_or_no

    if [ $? -gt 0 ]; then
        for file in "$TARGET_DIR"/{*,.*}; do
            
            BASE=$(/usr/bin/basename $file)

            [[ "$BASE" == "." || "$BASE" == ".." ]] && continue
            
            is_exclude $BASE 
            
            if [ $? -eq 0 ]; then
                print_msg "${LGREEN}SKIP${NORM} $file"
                continue
            else
                print_msg "$SUDO rm -rf $file"
                $SUDO rm -rf ${file}
            fi
        done
    fi

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
        print_msg "$target_parent is existed"
    else
        print_msg "$target_parent is not found"
        print_msg "---> $SUDO mkdir -p $target_parent"
        if [ $DEV_MODE -eq 0 ]; then
            $SUDO mkdir -p $target_parent
        fi
    fi
    copy_all $SOURCE_DIR/$path $TARGET_DIR/$path
done

print_msg "${LGREEN}DONE!${NORM}"
