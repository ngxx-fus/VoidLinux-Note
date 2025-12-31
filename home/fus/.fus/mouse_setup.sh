#!/bin/bash

# ==============================================================================
# @file        setup_all_mice.sh
# @brief       Auto-configure mice (Custom) & Reset Touchpads (Default).
# @details     1. Mice:      Apply Speed, Flat Accel, Swap Buttons.
#              2. Touchpads: Reset to Speed 0, Adaptive Accel, Normal Buttons.
# ==============================================================================

# --- CONFIGURATION (MOUSE ONLY) ---

# 1. SET_MOUSE_SPEED: Mouse sensitivity (-1.0 to 1.0)
MOUSE_SPEED=-0.2

# 2. SET_MOUSE_ACC: "adaptive" or "flat"
MOUSE_ACC="flat"

# 3. SET_MOUSE_SWAP: 0 = Normal, 1 = Left-handed
MOUSE_SWAP=1

# ==============================================================================

check_dependencies() {
    if ! command -v xinput &> /dev/null; then
        echo "[mouse_setup.sh] [ERROR] 'xinput' tool not found!"
        exit 1
    fi
}

# @func  apply_mouse_settings
# @brief Applies CUSTOM settings (For External Mice)
apply_mouse_settings() {
    local id=$1
    local name=$2
    local clean_speed=$(printf "%.2f" "$MOUSE_SPEED")

    # 1. Set Speed
    xinput set-prop "$id" "libinput Accel Speed" "$clean_speed" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        # 2. Set Accel Profile
        if [ "$MOUSE_ACC" == "flat" ]; then
            xinput set-prop "$id" "libinput Accel Profile Enabled" 0, 1 2>/dev/null
        else
            xinput set-prop "$id" "libinput Accel Profile Enabled" 1, 0 2>/dev/null
        fi

        # 3. Set Button Swap
        if [ "$MOUSE_SWAP" -eq 1 ]; then
            # Swap Left/Right
            xinput set-button-map "$id" 3 2 1 4 5 6 7 8 9 2>/dev/null
        else
            xinput set-button-map "$id" 1 2 3 4 5 6 7 8 9 2>/dev/null
        fi

        echo "[mouse_setup.sh] [MOUSE] Configured: ID [$id] ($name)"
    fi
}

# @func  reset_device_defaults
# @brief Resets settings to SYSTEM DEFAULTS (For Touchpads)
reset_device_defaults() {
    local id=$1
    local name=$2

    # 1. Reset Speed to 0.0 (System Default)
    xinput set-prop "$id" "libinput Accel Speed" 0.0 2>/dev/null

    # 2. Reset Accel to Adaptive (1, 0) - Standard behavior
    xinput set-prop "$id" "libinput Accel Profile Enabled" 1, 0 2>/dev/null

    # 3. Reset Button Map to Normal (1 2 3...)
    xinput set-button-map "$id" 1 2 3 4 5 6 7 8 9 2>/dev/null

    echo "[mouse_setup.sh] [TOUCHPAD] Reset to Defaults: ID [$id] ($dev_name)"
}

# --- MAIN EXECUTION ---

echo "[mouse_setup.sh] Scanning devices..."
check_dependencies

device_ids=$(xinput list | grep "slave  pointer" | grep -v "XTEST" | sed -n 's/.*id=\([0-9]*\).*/\1/p')

if [ -z "$device_ids" ]; then
    echo "[mouse_setup.sh] [WARN] No pointer devices found."
else
    for id in $device_ids; do
        dev_name=$(xinput list --name-only "$id" 2>/dev/null)
        
        # --- LOGIC PHÂN LOẠI ---
        # Nếu tên thiết bị chứa từ khóa Touchpad/Trackpad...
        if echo "$dev_name" | grep -qiE "touchpad|synaptics|trackpad|elan|alps|clickpad"; then
            # ==> RESET VỀ MẶC ĐỊNH
            reset_device_defaults "$id" "$dev_name"
        else
            # ==> ÁP DỤNG CẤU HÌNH CHUỘT (Swap, Speed...)
            apply_mouse_settings "$id" "$dev_name"
        fi
    done
fi

echo "[mouse_setup.sh] Done."
