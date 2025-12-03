#!/bin/bash

# ==============================================================================
# @file         setup_all_mice.sh
# @brief        Auto-configure all connected mice/touchpads (Speed, Accel, Swap).
# @details      1. Checks for 'xinput' dependency.
#               2. Scans xinput list, filters "slave pointers".
#               3. Applies settings indiscriminately (ignores errors from keyboards).
# ==============================================================================

# --- CONFIGURATION (EDIT HERE) ---

# 1. SET_MOUSE_SPEED: Mouse sensitivity
#    Range: -1.0 (Slowest) to 1.0 (Fastest). 0.0 is System Default.
#    @note: Value will be rounded to 2 decimal places (e.g., 0.256 -> 0.26).
#    Examples:
#       0.0   = Default speed
#       -0.5  = Slower (Common for high DPI mice)
#       0.25  = Faster
#       1.0   = Max speed
MOUSE_SPEED=-0.2

# 2. SET_MOUSE_ACC: Acceleration Profile
#    "adaptive" = Mouse cursor speed increases with hand speed (Default).
#    "flat"     = No acceleration (1:1 movement). SAME AS "NONE".
#                 (Best for muscle memory/gaming).
MOUSE_ACC="flat"

# 3. SET_MOUSE_SWAP: Swap Left/Right buttons
#    0 = Normal (Right-handed): Click=Left, Context=Right
#    1 = Swap (Left-handed):    Click=Right, Context=Left
MOUSE_SWAP=1

# ==============================================================================

# @func  check_dependencies
# @brief Checks if required tools are installed.
check_dependencies() {
    if ! command -v xinput &> /dev/null; then
        echo "[mouse_setup.sh] [ERROR] 'xinput' tool not found!"
        echo "[mouse_setup.sh] --> Please install it using Void Linux package manager:"
        echo "                   sudo xbps-install -S xinput"
        exit 1
    fi
}

# @func  apply_mouse_settings
# @brief Applies settings to a specific device ID
# @param $1 Device ID
# @param $2 Device Name
apply_mouse_settings() {
    local id=$1
    local name=$2
    local clean_speed

    # --- FORMAT SPEED VALUE ---
    # Enforce 2 decimal places to avoid driver errors with inputs like 0.000025
    clean_speed=$(printf "%.2f" "$MOUSE_SPEED")

    # --- 1. SET SPEED ---
    # Try setting speed. Redirect stderr to hide errors if device is not a mouse (e.g., keyboard).
    xinput set-prop "$id" "libinput Accel Speed" "$clean_speed" 2>/dev/null
    
    # Check if the previous command succeeded (Exit code 0 means it's a valid mouse/touchpad)
    if [ $? -eq 0 ]; then
        
        # --- 2. SET ACCELERATION PROFILE ---
        # Note: 'libinput Accel Profile Enabled' takes a boolean array usually:
        # 1, 0 = Adaptive
        # 0, 1 = Flat
        if [ "$MOUSE_ACC" == "flat" ]; then
            xinput set-prop "$id" "libinput Accel Profile Enabled" 0, 1 2>/dev/null
        elif [ "$MOUSE_ACC" == "adaptive" ]; then
            xinput set-prop "$id" "libinput Accel Profile Enabled" 1, 0 2>/dev/null
        fi

        # --- 3. SET BUTTON SWAP ---
        if [ "$MOUSE_SWAP" -eq 1 ]; then
            # Swap Left(1) and Right(3). Middle(2) stays same.
            xinput set-button-map "$id" 3 2 1 4 5 6 7 8 9 2>/dev/null
        else
            # Reset to Standard
            xinput set-button-map "$id" 1 2 3 4 5 6 7 8 9 2>/dev/null
        fi

        echo "[mouse_setup.sh] [OK] Configured: ID [$id] ($name) | Speed: $clean_speed | Acc: $MOUSE_ACC"
    fi
}

# --- MAIN EXECUTION ---

echo "[mouse_setup.sh] Starting Mouse Configuration..."

# 0. Check Dependencies
check_dependencies

# 1. Get list of IDs for "slave pointer" devices, excluding "XTEST"
#    sed command extracts only the number after "id="
device_ids=$(xinput list | grep "slave  pointer" | grep -v "XTEST" | sed -n 's/.*id=\([0-9]*\).*/\1/p')

# 2. Iterate through each device
if [ -z "$device_ids" ]; then
    echo "[mouse_setup.sh] [WARN] No pointer devices found."
else
    for id in $device_ids; do
        # Get device name cleanly
        dev_name=$(xinput list --name-only "$id" 2>/dev/null)
        
        # Apply settings
        apply_mouse_settings "$id" "$dev_name"
    done
fi

echo "[mouse_setup.sh] Configuration Finished."
