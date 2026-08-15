#!/bin/sh

: '/*
 * @file AutoMount.sh
 * @brief Automated partition verification, block device detection, and read-only mount service.
 */'

# Source SystemLog logging utilities using POSIX dot operator
. /home/fus/.fus/Utilities/SystemLog.sh

export TARGET_DEV="/dev/disk/by-uuid/f41f2609-d5df-414b-bb6d-d457f9004718" # "/dev/sdb1"
export TARGET_DIR="/mnt/disk0"
export UDEVADM_PATH="/usr/bin/udevadm"
export BLKID_PATH="/usr/bin/blkid"

SL_Entry "Mount_Disk0_Service.sh procedure initiated."

# Wait for system device events to settle if udevadm is available
if [ -x "$UDEVADM_PATH" ]; then
    "$UDEVADM_PATH" settle --timeout=5
fi

# Evaluate whether the target device node exists as a valid block device
if [ ! -b "$TARGET_DEV" ]; then
    SL_Exit 1 "Target device node '$TARGET_DEV' is not a valid block device. Terminating."
    
    # Abort service execution due to invalid block device
    exit 1
fi

SL_Info "Target block device node '$TARGET_DEV' verified."

# Evaluate whether the mount target directory exists
if ! SL_Exists "$TARGET_DIR"; then
    SL_Info "Mount directory '$TARGET_DIR' does not exist. Creating directory..."
    
    # Create target mount directory recursively
    mkdir -p "$TARGET_DIR"
fi

SL_Info "Unmounting any existing devices from mount point '$TARGET_DIR'..."

# Unmount target directory safely if currently mounted
umount -f "$TARGET_DIR" 2>/dev/null

SL_Info "Mounting partition '$TARGET_DEV' to target location '$TARGET_DIR'..."

# Detect filesystem type using blkid if available
fs_type=""
if [ -x "$BLKID_PATH" ]; then
    fs_type=$("$BLKID_PATH" -o value -s TYPE "$TARGET_DEV" 2>/dev/null)
fi

# Execute read-write mount operation based on detected filesystem
if [ "$fs_type" = "ntfs" ]; then
    # Mount NTFS partition using ntfs-3g driver if available
    mount -t ntfs-3g -o rw "$TARGET_DEV" "$TARGET_DIR" 2>/dev/null || mount -o rw "$TARGET_DEV" "$TARGET_DIR"
    mount_status=$?
elif [ -n "$fs_type" ]; then
    # Mount with explicitly detected filesystem
    mount -t "$fs_type" -o rw "$TARGET_DEV" "$TARGET_DIR"
    mount_status=$?
else
    # Fallback to standard kernel auto-detection
    mount -o rw "$TARGET_DEV" "$TARGET_DIR"
    mount_status=$?
fi

# Evaluate the partition mount status
if [ "$mount_status" -ne 0 ]; then
    SL_Exit "$mount_status" "Failed to mount '$TARGET_DEV' onto '$TARGET_DIR'."
    
    # Terminate service execution on mount failure
    exit "$mount_status"
fi

SL_Info "Successfully mounted '$TARGET_DEV' to '$TARGET_DIR'. Entering keep-alive loop..."

# Keep the Runit/Systemd daemon service running continuously in the foreground
while :; do
    # Pause execution for 10 minutes per cycle
    sleep 600
done

# Terminate script with success code if loop ever exits
exit 0
