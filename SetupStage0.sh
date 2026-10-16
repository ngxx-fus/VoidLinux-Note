#!/usr/bin/env bash
# ==============================================================================
# SetupStage0.sh
# Stage 0: Core System, Repositories, CPU/GPU Drivers, Firmware, Daemons & Libs
# Target : Void Linux (x86_64 Laptop/PC - replacing UbuntuBSPWM)
# Scope  : Strictly package & driver installation (NO system/user config changes)
# ==============================================================================

set -euo pipefail
IFS=$' \t\n'
umask 022

# ==============================================================================
# SECURITY & RUNTIME CONSTANTS
# ==============================================================================
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
readonly LOCK_FILE="/tmp/void_setup_stage0.lock"
readonly LOG_FILE="/tmp/void_setup_stage0_$(date +%Y%m%d_%H%M%S).log"

CONFIRM_ALL=0
DRY_RUN=0
FORCE_DISTRO=0

# Track installation results
declare -a INSTALLED_GROUPS=()
declare -a SKIPPED_GROUPS=()
declare -a FAILED_PKGS=()

# ==============================================================================
# LOGGING & CLEANUP (SECURITY HARDENED)
# ==============================================================================
InitSecurityAndLog() {
    # Prevent symlink attacks on lock/log files
    if [[ -L "$LOCK_FILE" ]]; then
        echo "[-] SECURITY ERROR: Lockfile '$LOCK_FILE' is a symbolic link. Aborting." >&2
        exit 1
    fi
    if [[ -f "$LOCK_FILE" ]]; then
        local existing_pid
        existing_pid="$(cat "$LOCK_FILE" 2>/dev/null || true)"
        if [[ -n "$existing_pid" ]] && kill -0 "$existing_pid" 2>/dev/null; then
            echo "[-] Error: Another instance of $SCRIPT_NAME is running (PID: $existing_pid)." >&2
            exit 1
        fi
        rm -f "$LOCK_FILE"
    fi

    echo "$$" > "$LOCK_FILE"
    chmod 600 "$LOCK_FILE"

    # Create log file with strict owner-only read/write permissions (0600)
    install -m 600 /dev/null "$LOG_FILE"
}

Cleanup() {
    rm -f "$LOCK_FILE" 2>/dev/null || true
}
trap Cleanup EXIT INT TERM

LogInfo() {
    printf "\033[1;34m[*]\033[0m %s\n" "$*"
    printf "[%s] [INFO] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

LogOk() {
    printf "\033[1;32m[+]\033[0m %s\n" "$*"
    printf "[%s] [OK]   %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

LogWarn() {
    printf "\033[1;33m[!]\033[0m %s\n" "$*" >&2
    printf "[%s] [WARN] %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

LogErr() {
    printf "\033[1;31m[-]\033[0m %s\n" "$*" >&2
    printf "[%s] [ERR]  %s\n" "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >> "$LOG_FILE"
}

# ==============================================================================
# CLI OPTIONS & INTERACTIVE PROMPT
# ==============================================================================
PrintUsage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Stage 0 Void Linux Installer (x86_64):
  Installs official repositories, CPU microcode, GPU/Audio/Network firmware,
  Mesa/Vulkan drivers, core system daemons, CLI utilities, and build libraries.
  NOTE: This script ONLY installs packages. It does NOT modify dotfiles or services.

Options:
  -y, --yes, -a, --all    Non-interactive mode; install all package groups
  -n, --dry-run           Preview commands without installing any packages
  --force-distro          Allow running checks on non-Void systems (with --dry-run)
  -h, --help              Show this help message and exit

Interactive Choices:
  [y] Yes  - Install this package group
  [n] No   - Skip this package group
  [a] All  - Install this and all remaining package groups
  [q] Quit - Abort installation safely
EOF
}

for arg in "$@"; do
    case "$arg" in
        -y|--yes|-a|--all)
            CONFIRM_ALL=1
            ;;
        -n|--dry-run)
            DRY_RUN=1
            ;;
        --force-distro)
            FORCE_DISTRO=1
            ;;
        -h|--help)
            PrintUsage
            exit 0
            ;;
        *)
            echo "[-] Error: Unknown option '$arg'" >&2
            PrintUsage
            exit 1
            ;;
    esac
done

UserConfirmYNA() {
    local prompt_msg="$1"
    local user_choice=""

    if [[ "$CONFIRM_ALL" -eq 1 ]]; then
        return 0
    fi

    while true; do
        read -n 1 -r -p "${prompt_msg} [y/n/a/q]: " user_choice </dev/tty
        echo ""
        case "$user_choice" in
            [yY]) return 0 ;;
            [nN]) return 1 ;;
            [aA])
                CONFIRM_ALL=1
                return 0
                ;;
            [qQ])
                LogWarn "Aborted by user."
                exit 0
                ;;
            *)
                echo "Please press y (yes), n (no), a (all), or q (quit)."
                ;;
        esac
    done
}

# ==============================================================================
# ENVIRONMENT & SECURITY VERIFICATION
# ==============================================================================
VerifyEnvironment() {
    LogInfo "Running pre-flight environment and security checks..."

    # 1. Architecture check
    local arch
    arch="$(uname -m)"
    if [[ "$arch" != "x86_64" ]]; then
        LogWarn "Detected architecture '$arch' (expected 'x86_64')."
        if ! UserConfirmYNA "Continue on '$arch' anyway?"; then
            exit 1
        fi
    else
        LogOk "Architecture verified: x86_64"
    fi

    # 2. Void Linux / xbps check
    if ! command -v xbps-install >/dev/null 2>&1; then
        if [[ "$DRY_RUN" -eq 1 || "$FORCE_DISTRO" -eq 1 ]]; then
            LogWarn "xbps-install not found (running in preview/dry-run mode)."
        else
            LogErr "xbps-install not found! This script must be run on Void Linux (or use --dry-run to preview)."
            exit 1
        fi
    else
        LogOk "Package manager verified: xbps-install"
    fi

    # 3. Privilege check
    if [[ "$DRY_RUN" -eq 0 ]]; then
        if [[ "$EUID" -eq 0 ]]; then
            SUDO_CMD=()
            LogOk "Running with root privileges."
        elif command -v sudo >/dev/null 2>&1; then
            SUDO_CMD=(sudo)
            LogInfo "Validating sudo credentials..."
            sudo -v
        else
            LogErr "Neither running as root nor is 'sudo' available. Cannot install packages."
            exit 1
        fi
    else
        SUDO_CMD=(sudo)
        LogInfo "DRY-RUN mode enabled: No system changes will be made."
    fi
}

# ==============================================================================
# SAFE PACKAGE INSTALLATION ENGINE
# ==============================================================================
RunXbpsCmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf "  \033[0;36m[DRY-RUN]\033[0m %s\n" "${SUDO_CMD[*]} $*"
        return 0
    fi
    "${SUDO_CMD[@]}" "$@" 2>&1 | tee -a "$LOG_FILE"
}

InstallGroup() {
    local group_title="$1"
    shift
    local -a pkgs=("$@")

    echo ""
    echo "=============================================================================="
    LogInfo "Group: ${group_title}"
    printf "  Packages (%d): %s\n" "${#pkgs[@]}" "${pkgs[*]}"
    echo "=============================================================================="

    if ! UserConfirmYNA "Install group '${group_title}'?"; then
        LogWarn "Skipped group: ${group_title}"
        SKIPPED_GROUPS+=("$group_title")
        return 0
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        RunXbpsCmd xbps-install -Sy "${pkgs[@]}"
        INSTALLED_GROUPS+=("$group_title (dry-run)")
        return 0
    fi

    # Attempt batch installation first for speed and dependency resolution
    if "${SUDO_CMD[@]}" xbps-install -Sy "${pkgs[@]}" >> "$LOG_FILE" 2>&1; then
        LogOk "Successfully installed group: ${group_title}"
        INSTALLED_GROUPS+=("$group_title")
        return 0
    fi

    # Fallback: Install package-by-package if batch failed (e.g., one package missing in repo)
    LogWarn "Batch install encountered an issue for '${group_title}'. Retrying package-by-package..."
    for pkg in "${pkgs[@]}"; do
        if "${SUDO_CMD[@]}" xbps-install -Sy "$pkg" >> "$LOG_FILE" 2>&1; then
            LogOk "  Installed: $pkg"
        else
            LogErr "  Failed/Unavailable package: $pkg"
            FAILED_PKGS+=("$pkg ($group_title)")
        fi
    done
    INSTALLED_GROUPS+=("$group_title (partial)")
}

# ==============================================================================
# HARDWARE AUTO-DETECTION (CPU & GPU FOR x86_64)
# ==============================================================================
DetectHardwarePackages() {
    HW_CPU_PKGS=()
    HW_GPU_PKGS=(
        mesa
        mesa-dri
        mesa-vaapi
        mesa-vdpau
        mesa-demos
        libva-utils
        vulkan-loader
        xf86-video-modesetting
    )

    local cpu_vendor=""
    if [[ -r /proc/cpuinfo ]]; then
        cpu_vendor="$(grep -m1 'vendor_id' /proc/cpuinfo | awk '{print $3}' || true)"
    fi

    case "$cpu_vendor" in
        GenuineIntel)
            LogInfo "Detected Intel CPU -> Selecting intel-ucode & Intel firmware"
            HW_CPU_PKGS+=(intel-ucode linux-firmware-intel)
            ;;
        AuthenticAMD)
            LogInfo "Detected AMD CPU -> Selecting linux-firmware-amd"
            HW_CPU_PKGS+=(linux-firmware-amd)
            ;;
        *)
            LogInfo "Generic x86_64 CPU -> Selecting both Intel & AMD firmware"
            HW_CPU_PKGS+=(intel-ucode linux-firmware-intel linux-firmware-amd)
            ;;
    esac

    # Detect GPU vendor via lspci if available, else default to Intel + Mesa stack
    if command -v lspci >/dev/null 2>&1; then
        local gpu_info
        gpu_info="$(lspci | grep -iE 'vga|3d|display' || true)"
        if echo "$gpu_info" | grep -qi "intel"; then
            LogInfo "Detected Intel GPU -> Adding mesa-vulkan-intel & intel-video-accel"
            HW_GPU_PKGS+=(mesa-vulkan-intel intel-video-accel)
        fi
        if echo "$gpu_info" | grep -qiE "amd|ati|radeon"; then
            LogInfo "Detected AMD GPU -> Adding mesa-vulkan-radeon & xf86-video-amdgpu"
            HW_GPU_PKGS+=(mesa-vulkan-radeon xf86-video-amdgpu)
        fi
        if echo "$gpu_info" | grep -qi "nvidia"; then
            LogWarn "Detected NVIDIA GPU -> Keeping Mesa/modesetting safe defaults (install 'nvidia' manually if proprietary driver is desired)"
        fi
    else
        # Default safe Intel/AMD Vulkan drivers for modern laptops (incl. Intel Ultra / Arrow Lake)
        HW_GPU_PKGS+=(mesa-vulkan-intel intel-video-accel)
    fi
}

# ==============================================================================
# STAGE 0 PACKAGE DEFINITIONS
# ==============================================================================
RunStage0() {
    InitSecurityAndLog
    LogInfo "Log file initialized at: $LOG_FILE"
    VerifyEnvironment

    # --------------------------------------------------------------------------
    # STEP 1: Sync & Upgrade XBPS + Base System + Repositories
    # --------------------------------------------------------------------------
    echo ""
    echo "=============================================================================="
    LogInfo "Step 1: Sync XBPS Package Manager & Enable Official Nonfree/Multilib Repos"
    echo "=============================================================================="
    if UserConfirmYNA "Update xbps, sync system packages, and enable void-repo-nonfree?"; then
        LogInfo "Updating xbps package manager first (required by Void Linux)..."
        RunXbpsCmd xbps-install -Syu xbps || true
        LogInfo "Performing full system sync & update..."
        RunXbpsCmd xbps-install -Syu
        LogInfo "Installing void-repo-nonfree and void-repo-multilib..."
        RunXbpsCmd xbps-install -Sy void-repo-nonfree void-repo-multilib
        LogInfo "Refreshing repository index for nonfree/multilib packages..."
        RunXbpsCmd xbps-install -S
        INSTALLED_GROUPS+=("01-XBPS-and-Repos")
    else
        SKIPPED_GROUPS+=("01-XBPS-and-Repos")
    fi

    # --------------------------------------------------------------------------
    # STEP 2: CPU Microcode, Kernel Firmware & SOF Audio Firmware
    # --------------------------------------------------------------------------
    DetectHardwarePackages
    local -a firmware_pkgs=(
        "${HW_CPU_PKGS[@]}"
        linux-firmware
        linux-firmware-network
        sof-firmware
        pciutils
        usbutils
    )
    InstallGroup "02-Firmware-and-Microcode" "${firmware_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 3: GPU Drivers & Hardware Acceleration (Mesa / VA-API / Vulkan)
    # --------------------------------------------------------------------------
    InstallGroup "03-GPU-and-Acceleration-Drivers" "${HW_GPU_PKGS[@]}"

    # --------------------------------------------------------------------------
    # STEP 4: Core System Daemons, Session, Power & Hardware Control
    # --------------------------------------------------------------------------
    local -a system_daemon_pkgs=(
        dbus
        dbus-x11
        elogind
        polkit
        lxsession
        acpid
        upower
        power-profiles-daemon
        brightnessctl
        lm_sensors
        udisks2
        efibootmgr
    )
    InstallGroup "04-System-Session-and-Power" "${system_daemon_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 5: Network, Wireless & Bluetooth Stack
    # --------------------------------------------------------------------------
    local -a network_pkgs=(
        NetworkManager
        network-manager-applet
        bluez
        blueman
        rfkill
        openssh
        curl
        wget
    )
    InstallGroup "05-Network-and-Bluetooth" "${network_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 6: Audio Stack (PipeWire + PulseAudio Compatibility + Mixer Tools)
    # --------------------------------------------------------------------------
    local -a audio_pkgs=(
        pipewire
        wireplumber
        alsa-pipewire
        libpulseaudio
        pulseaudio-utils
        alsa-utils
        pamixer
        pavucontrol
    )
    InstallGroup "06-Audio-PipeWire-Stack" "${audio_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 7: Essential CLI Utilities, Shells & System Monitors
    # --------------------------------------------------------------------------
    local -a cli_pkgs=(
        bash
        zsh
        dash
        tmux
        vim
        neovim
        git
        github-cli
        btop
        htop
        iotop
        duf
        fastfetch
        tree
        ripgrep
        fd
        fzf
        plocate
        unzip
        tar
        gzip
        diffutils
        findutils
        grep
        util-linux
        v4l-utils
        stress
    )
    InstallGroup "07-Core-CLI-and-Shell-Tools" "${cli_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 8: Compilers, Toolchains & Development Libraries (for BSPWM/X11 helpers)
    # --------------------------------------------------------------------------
    local -a dev_toolchain_pkgs=(
        base-devel
        gcc
        make
        cmake
        meson
        ninja
        autoconf
        pkg-config
        clang-tools-extra
        cargo
        rust
        python3
        python3-pip
        python3-setuptools
        python3-numpy
        python3-opencv
        python3-dbus
        nodejs
        doxygen
        graphviz
    )
    InstallGroup "08-Dev-Compilers-and-Toolchains" "${dev_toolchain_pkgs[@]}"

    local -a dev_libs_pkgs=(
        zlib-devel
        alsa-lib-devel
        cairo-devel
        libev-devel
        fontconfig-devel
        giflib-devel
        glib-devel
        libjpeg-turbo-devel
        lapack-devel
        openblas-devel
        pam-devel
        libpng-devel
        pulseaudio-devel
        SDL2-devel
        SDL2_gfx-devel
        SDL2_image-devel
        SDL2_mixer-devel
        SDL2_net-devel
        SDL2_ttf-devel
        wayland-devel
        wayland-protocols
        libX11-devel
        libxcb-devel
        xcb-util-devel
        xcb-util-image-devel
        xcb-util-keysyms-devel
        xcb-util-renderutil-devel
        xcb-util-wm-devel
        xcb-util-xrm-devel
        libXcomposite-devel
        libXdamage-devel
        libXext-devel
        libXfixes-devel
        libXft-devel
        libXinerama-devel
        libxkbcommon-devel
        libXrandr-devel
        libXrender-devel
        libyaml-devel
        qt6-base-devel
        qt6-declarative-devel
        qt6-shadertools-devel
    )
    InstallGroup "09-X11-and-System-Devel-Libraries" "${dev_libs_pkgs[@]}"

    # --------------------------------------------------------------------------
    # SUMMARY REPORT
    # --------------------------------------------------------------------------
    echo ""
    echo "=============================================================================="
    LogOk "SetupStage0.sh completed!"
    echo "=============================================================================="
    printf "  Log File         : %s\n" "$LOG_FILE"
    printf "  Installed Groups : %d (%s)\n" "${#INSTALLED_GROUPS[@]}" "${INSTALLED_GROUPS[*]:-none}"
    printf "  Skipped Groups   : %d (%s)\n" "${#SKIPPED_GROUPS[@]}" "${SKIPPED_GROUPS[*]:-none}"
    if [[ "${#FAILED_PKGS[@]}" -gt 0 ]]; then
        LogWarn "Packages that failed or were unavailable (${#FAILED_PKGS[@]}):"
        for fp in "${FAILED_PKGS[@]}"; do
            printf "    - %s\n" "$fp"
        done
    else
        LogOk "All requested packages processed cleanly with zero failures."
    fi
    echo "=============================================================================="
    LogInfo "Next step: Run ./SetupStage1.sh to install Xorg, BSPWM, CopyQ, Fcitx5, and UI apps."
}

RunStage0
