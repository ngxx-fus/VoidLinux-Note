#!/bin/zsh 


PWD=$(pwd)
LOG_FILEPATH=$PWD/mount_sdcard.log
MOUNT_EXTERNAL_SSD_LOG=y
MOUNTPOINT=/mnt/ExtSSD
DEV=/dev/sdc


print_msg(){
    case "${MOUNT_SDCARD_LOG}" in
        [Yy])
            echo "[LOG] $* ${NORM}"
            ;;
        *)
            ;;
    esac
}

print_msg "Location: $PWD"

echo "Source shell_utils.sh at ~/.fus"
source /home/fus/.fus/shell_utils.sh 

check_external_ssd_valid(){
    if ls $DEV > /dev/null 2>&1; then
        print_msg "${LYELLOW}---> Specified external SSD detected!${NORM}"
        return 0
    else
        print_msg "${LRED}---> No specified external SSD found.${NORM}"
        return 1
    fi
}


print_msg "Check ${BOLD}\`ls $DEV\`${NORM} ?"
check_external_ssd_valid
if [ $? -eq 1 ] ; then
    print_msg "${LYELLOW}---> Abort!!! ${NORM}"
    exit 1
fi

print_msg "[DEFAULT] ${LCYAN}DEV=${DEV}${NORM}"
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
print_msg "Mount ${LYELLOW}${DEV}${NORM} --> ${LYELLOW}${MOUNTPOINT}${NORM}"
sudo mount ${DEV} ${MOUNTPOINT}
if [ $? -eq 0 ]; then
    print_msg "${LGREEN}OK!${NORM}"
fi
lsblk
print_msg "DONE --> EXIT :> ${NORM}"

