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

print_msg "Source text_effects at ~/.fus"
source /home/fus/.fus/text_effects

print_msg "Check ${BOLD}\`ls /dev/mmcblk*\`${NORM} has mmcblk# ?"
check_sdcard_valid
if [ $? -eq 1 ] ; then
    print_msg "${LYELLOW}---> Abort!!! ${NORM}"
    exit 1
fi

print_msg "[DEFAULT] ${LCYAN}MMCBLK_ID=${MMCBLK_ID}"
print_msg "[DEFAULT] ${LCYAN}MMCBLK_PART_ID=${MMCBLK_PART_ID}"
print_msg "[DEFAULT] ${LCYAN}--> /dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID}${NORM}"
print_msg "[DEFAULT] ${LCYAN}MOUNTPOINT=${MOUNTPOINT}"

if [ -d "$MOUNTPOINT" ]; then
    print_msg "${LYELLOW}$MOUNTPOINT is existed!"
    mountpoint -q $MOUNTPOINT
    if [ $? -eq 0 ]; then
        print_msg "${LRED}$MOUNTPOINT is mounted!"
        print_msg "${LYELLOW}---> Abort!!! ${NORM}"
        exit 1
    fi
    print_msg "${LYELLOW}---> Remove current $MOUNTPOINT" 
    sudo rm -rf $MOUNTPOINT
    if [ $? -eq 0 ]; then
        print_msg "${LGREEN}OK"
    fi
fi
print_msg "${LYELLOW}---> Create $MOUNTPOINT" 
sudo mkdir -p $MOUNTPOINT
if [ $? -eq 0 ]; then
    print_msg "${LGREEN}OK!"
fi
print_msg "Mount ${LYELLOW}/dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID}${NORM} --> ${LYELLOW}${MOUNTPOINT}"
sudo mount /dev/mmcblk${MMCBLK_ID}p${MMCBLK_PART_ID} ${MOUNTPOINT}
if [ $? -eq 0 ]; then
    print_msg "${LGREEN}OK!"
fi
lsblk
print_msg "DONE --> EXIT :> "
