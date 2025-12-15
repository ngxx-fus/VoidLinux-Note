#!/bin/zsh 

PWD=$(pwd)
LOG_FILEPATH=$PWD/mount_sdcard.log
MOUNT_SDCARD_LOG=y
MOUNTPOINT=/mnt/SD
MMCBLK_ID=0
MMCBLK_PART_ID=1

print_msg(){
    case "${MOUNT_SDCARD_LOG}" in
        [Yy])
            echo "[LOG] $* ${NORM}"
            ;;
        *)
            ;;
    esac
}

check_sdcard_valid(){
    if ls /dev/mmcblk* > /dev/null 2>&1; then
        print_msg "${LYELLOW}---> SD card detected!${NORM}"
        return 0
    else
        print_msg "${LRED}---> No SD card found.${NORM}"
        return 1
    fi
}

print_msg "Location: $PWD"

print_msg "Source shell_utils.sh at ~/.fus"
source /home/fus/.fus/shell_utils.sh

print_msg "Check ${BOLD}\`ls /dev/mmcblk*\`${NORM} has mmcblk# ?"
check_sdcard_valid
if [ $? -eq 1 ] ; then
    print_msg "${LYELLOW}---> Abort!!! ${NORM}"
    exit 1
fi

print_msg "[DEFAULT] ${LCYAN}MMCBLK_ID=${MMCBLK_ID}${NORM}"
print_msg "[DEFAULT] ${LCYAN}MMCBLK_PART_ID=${MMCBLK_PART_ID}${NORM}"
print_msg "[DEFAULT] ${LCYAN}--> /dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID}${NORM}"
print_msg "[DEFAULT] ${LCYAN}MOUNTPOINT=${MOUNTPOINT}${NORM}"

if [ -d "$MOUNTPOINT" ]; then
    print_msg "${LYELLOW}$MOUNTPOINT is existed!${NORM}"
    mountpoint -q $MOUNTPOINT
    if [ $? -eq 0 ]; then
        print_msg "${LRED}$MOUNTPOINT is mounted!${NORM}"
        print_msg "${LYELLOW}---> Abort!!! ${NORM}"
        exit 1
    fi
    print_msg "${LYELLOW}---> Remove current $MOUNTPOINT${NORM}" 
    sudo rm -rf $MOUNTPOINT
    if [ $? -eq 0 ]; then
        print_msg "${LGREEN}OK${NORM}"
    fi
fi
print_msg "${LYELLOW}---> Create $MOUNTPOINT${NORM}" 
sudo mkdir -p $MOUNTPOINT
if [ $? -eq 0 ]; then
    print_msg "${LGREEN}OK!${NORM}"
fi
print_msg "Mount ${LYELLOW}/dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID}${NORM} --> ${LYELLOW}${MOUNTPOINT}${NORM}"
sudo mount /dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID} ${MOUNTPOINT}
if [ $? -eq 0 ]; then
    print_msg "${LGREEN}OK!${NORM}"
fi
lsblk
print_msg "DONE --> EXIT :> ${NORM}"
