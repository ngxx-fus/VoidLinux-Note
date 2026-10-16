#!/usr/bin/env bash
# ==============================================================================
# SetupStage1.sh
# Stage 1: Xorg Server, Input Drivers, BSPWM UI Stack, CopyQ, Fcitx5 & Desktop Apps
# Target : Void Linux (x86_64 Laptop/PC - replacing UbuntuBSPWM)
# Scope  : Strictly package installation (NO dotfiles or service config changes)
# ==============================================================================

set -euo pipefail
IFS=$' \t\n'
umask 022

# ==============================================================================
# SECURITY & RUNTIME CONSTANTS
# ==============================================================================
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
readonly LOCK_FILE="/tmp/void_setup_stage1.lock"
readonly LOG_FILE="/tmp/void_setup_stage1_$(date +%Y%m%d_%H%M%S).log"

CONFIRM_ALL=0
DRY_RUN=0
FORCE_DISTRO=0

declare -a INSTALLED_GROUPS=()
declare -a SKIPPED_GROUPS=()
declare -a FAILED_PKGS=()

# ==============================================================================
# LOGGING & CLEANUP (SECURITY HARDENED)
# ==============================================================================
InitSecurityAndLog() {
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

Stage 1 Void Linux UI & Desktop Installer (x86_64):
  Installs Xorg server, input drivers, BSPWM + SXHKD + Polybar + Rofi + Picom + Dunst,
  CopyQ clipboard manager, Flameshot, Fcitx5 (Vietnamese), Thunar, Fonts/Themes, and GUI apps.
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

    # Attempt batch installation first
    if "${SUDO_CMD[@]}" xbps-install -Sy "${pkgs[@]}" >> "$LOG_FILE" 2>&1; then
        LogOk "Successfully installed group: ${group_title}"
        INSTALLED_GROUPS+=("$group_title")
        return 0
    fi

    # Fallback: Install package-by-package if batch failed
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
# STAGE 1 PACKAGE DEFINITIONS (XORG, BSPWM, COPYQ, FCITX5, UI APPS)
# ==============================================================================
RunStage1() {
    InitSecurityAndLog
    LogInfo "Log file initialized at: $LOG_FILE"
    VerifyEnvironment

    # --------------------------------------------------------------------------
    # STEP 1: Xorg Server, Session Launchers, Display & Input Drivers
    # --------------------------------------------------------------------------
    local -a xorg_pkgs=(
        xorg-minimal
        xorg-apps
        xorg-input-drivers
        xf86-input-libinput
        xf86-video-modesetting
        xinit
        xauth
        xrandr
        xhost
        xdpyinfo
        xset
        xsetroot
        xprop
        xwininfo
        setxkbmap
        xcape
        xdotool
        xclip
        xsel
        xdg-utils
        xdg-user-dirs
    )
    InstallGroup "01-Xorg-Server-and-Input-Utils" "${xorg_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 2: BSPWM Window Manager, Bar, Launcher, Compositor & Notifications
    # --------------------------------------------------------------------------
    local -a bspwm_core_pkgs=(
        bspwm
        sxhkd
        polybar
        rofi
        picom
        dunst
        libnotify
        feh
        touchegg
    )
    InstallGroup "02-BSPWM-Desktop-Core" "${bspwm_core_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 3: Clipboard (CopyQ), Screenshot (Flameshot/Maim/Scrot) & Lockscreen
    # --------------------------------------------------------------------------
    local -a clipboard_screenshot_pkgs=(
        copyq
        flameshot
        maim
        scrot
        wl-clipboard
        i3lock-color
        ImageMagick
        bc
    )
    InstallGroup "03-CopyQ-Screenshot-and-Lockscreen" "${clipboard_screenshot_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 4: Input Method Stack (Fcitx5 + Vietnamese Bamboo/Unikey + GTK/Qt)
    # --------------------------------------------------------------------------
    local -a fcitx5_pkgs=(
        fcitx5
        fcitx5-bamboo
        fcitx5-unikey
        fcitx5-configtool
        fcitx5-gtk+2
        fcitx5-gtk+3
        fcitx5-gtk4
        fcitx5-qt5
        fcitx5-qt6
        fcitx5-icons
    )
    InstallGroup "04-Fcitx5-Input-Method" "${fcitx5_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 5: Terminal, File Manager (Thunar) & GTK/Icon Themes
    # --------------------------------------------------------------------------
    local -a desktop_tools_pkgs=(
        alacritty
        Thunar
        thunar-volman
        thunar-archive-plugin
        thunar-media-tags-plugin
        gvfs
        gvfs-mtp
        gvfs-afc
        xfce4-appfinder
        lxappearance
        arc-theme
        papirus-icon-theme
        gtk+3
        yad
    )
    InstallGroup "05-Terminal-Thunar-and-Themes" "${desktop_tools_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 6: Fonts (JetBrains Mono, Nerd Fonts, FontAwesome, DejaVu, Noto)
    # --------------------------------------------------------------------------
    local -a font_pkgs=(
        dejavu-fonts-ttf
        liberation-fonts-ttf
        font-jetbrains-mono-ttf
        font-awesome
        font-awesome5
        font-awesome6
        nerd-fonts-symbols-ttf
        noto-fonts-ttf
        noto-fonts-emoji
        noto-fonts-cjk
    )
    InstallGroup "06-UI-and-Icon-Fonts" "${font_pkgs[@]}"

    # --------------------------------------------------------------------------
    # STEP 7: Daily Desktop & Media Applications
    # --------------------------------------------------------------------------
    local -a gui_apps_pkgs=(
        firefox
        chromium
        vlc
        ffmpeg
        obs
        xournalpp
        gnome-calculator
        cheese
    )
    InstallGroup "07-Desktop-and-Media-Apps" "${gui_apps_pkgs[@]}"

    # --------------------------------------------------------------------------
    # SUMMARY REPORT
    # --------------------------------------------------------------------------
    echo ""
    echo "=============================================================================="
    LogOk "SetupStage1.sh completed!"
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
        LogOk "All requested UI packages processed cleanly with zero failures."
    fi
    echo "=============================================================================="
    LogInfo "All Stage 0 & Stage 1 packages are ready. You can proceed to service/dotfiles setup next."
}

RunStage1
