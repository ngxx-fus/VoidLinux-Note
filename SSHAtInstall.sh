#!/usr/bin/env bash
# ==============================================================================
# SSHAtInstall.sh
# Bootstrap OpenSSH (sshd) + Zsh shell during Void Linux Live ISO installation
# or on first boot of a minimal Void Linux base system.
# ==============================================================================

set -euo pipefail
IFS=$' \t\n'
umask 022

readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
DRY_RUN=0
CONFIRM_ALL=0
ALLOW_ROOT_SSH=0
TARGET_MNT=""

PrintUsage() {
    cat <<EOF
Usage: $SCRIPT_NAME [OPTIONS]

Bootstrap SSH server (sshd) and Zsh shell during Void Linux installation
(Live ISO environment) or on a freshly installed Void Linux base system.

Features:
  1. Installs & enables OpenSSH server (/var/service/sshd) and prints LAN IP.
  2. Installs Zsh, sets up Void Linux aliases/completion, and switches login shell to /bin/zsh.
  3. Optional: Injects sshd + zsh directly into /mnt after running void-installer
     so the new system has SSH and Zsh ready immediately upon first reboot.

Options:
  -y, --yes               Confirm all prompts automatically
  -r, --permit-root       Allow root SSH login (useful during initial install)
  -m, --mnt <DIR>         Also bootstrap sshd + zsh inside mounted target (e.g. /mnt)
  -n, --dry-run           Preview commands without making changes
  -h, --help              Display this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes)
            CONFIRM_ALL=1
            shift
            ;;
        -r|--permit-root)
            ALLOW_ROOT_SSH=1
            shift
            ;;
        -m|--mnt)
            TARGET_MNT="${2:-/mnt}"
            shift 2
            ;;
        -n|--dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            PrintUsage
            exit 0
            ;;
        *)
            echo "[-] Unknown option: $1" >&2
            PrintUsage
            exit 1
            ;;
    esac
done

LogInfo() { printf "\033[1;34m[*]\033[0m %s\n" "$*"; }
LogOk()   { printf "\033[1;32m[+]\033[0m %s\n" "$*"; }
LogWarn() { printf "\033[1;33m[!]\033[0m %s\n" "$*" >&2; }
LogErr()  { printf "\033[1;31m[-]\033[0m %s\n" "$*" >&2; }

UserConfirm() {
    local prompt_msg="$1"
    if [[ "$CONFIRM_ALL" -eq 1 ]]; then
        return 0
    fi
    local ans=""
    read -n 1 -r -p "${prompt_msg} [y/N]: " ans </dev/tty
    echo ""
    [[ "$ans" =~ ^[yY]$ ]]
}

RunCmd() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        printf "  \033[0;36m[DRY-RUN]\033[0m %s\n" "$*"
        return 0
    fi
    "$@"
}

# Elevate privileges if not root
if [[ "$EUID" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        SUDO=(sudo)
    else
        LogErr "Please run this script as root or with sudo."
        exit 1
    fi
else
    SUDO=()
fi

# ==============================================================================
# 1. INSTALL ZSH & OPENSSH ON CURRENT ENVIRONMENT (LIVE ISO OR HOST)
# ==============================================================================
SetupCurrentSystem() {
    LogInfo "Step 1: Installing openssh, zsh, git, curl via xbps..."
    RunCmd "${SUDO[@]}" xbps-install -Sy xbps || true
    RunCmd "${SUDO[@]}" xbps-install -Sy openssh zsh git curl

    # --------------------------------------------------------------------------
    # Configure Zsh shell & sensible default .zshrc for install session
    # --------------------------------------------------------------------------
    LogInfo "Step 2: Configuring Zsh shell for current users..."
    local target_users=("root")
    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        target_users+=("${SUDO_USER}")
    elif id anon >/dev/null 2>&1; then
        target_users+=("anon")
    fi

    for u in "${target_users[@]}"; do
        local u_home
        u_home="$(getent passwd "$u" | cut -d: -f6 || echo "/root")"

        if [[ -x /bin/zsh ]]; then
            LogInfo "Setting login shell to /bin/zsh for user '$u'..."
            RunCmd "${SUDO[@]}" usermod -s /bin/zsh "$u"
        fi

        # Create a clean bootstrap .zshrc if the user doesn't have one yet
        if [[ ! -f "${u_home}/.zshrc" ]]; then
            LogInfo "Creating bootstrap ${u_home}/.zshrc with completion & xbps aliases..."
            if [[ "$DRY_RUN" -eq 0 ]]; then
                cat <<'EOF' | "${SUDO[@]}" tee "${u_home}/.zshrc" >/dev/null
# Bootstrap Zsh Configuration for Void Linux Install / Live Session
autoload -Uz compinit promptinit
compinit
promptinit

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000
setopt HIST_IGNORE_DUPS SHARE_HISTORY INTERACTIVE_COMMENTS

PROMPT='%F{cyan}%n@%m%f %F{green}%~%f %# '

# Void Linux XBPS quick aliases
alias iy="sudo xbps-install -Sy"
alias iuy="sudo xbps-install -Syu"
alias r="sudo xbps-remove -Ry"
alias q="xbps-query -Rs"
alias ll="ls -lath --color=auto"
alias la="ls -A --color=auto"
EOF
                "${SUDO[@]}" chown "${u}:$(id -gn "$u" 2>/dev/null || echo "$u")" "${u_home}/.zshrc"
            else
                printf "  \033[0;36m[DRY-RUN]\033[0m Write bootstrap %s/.zshrc\n" "$u_home"
            fi
        fi
    done

    # --------------------------------------------------------------------------
    # Configure & Harden OpenSSH Daemon (sshd)
    # --------------------------------------------------------------------------
    LogInfo "Step 3: Configuring and enabling OpenSSH daemon (sshd)..."
    if [[ "$ALLOW_ROOT_SSH" -eq 1 ]] || UserConfirm "Allow root login over SSH for this installation session?"; then
        if [[ "$DRY_RUN" -eq 0 && -f /etc/ssh/sshd_config ]]; then
            "${SUDO[@]}" sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
            "${SUDO[@]}" sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        else
            printf "  \033[0;36m[DRY-RUN]\033[0m Set PermitRootLogin yes & PasswordAuthentication yes in /etc/ssh/sshd_config\n"
        fi
    fi

    # Generate host keys and validate sshd_config before starting/restarting
    RunCmd "${SUDO[@]}" ssh-keygen -A
    if command -v sshd >/dev/null 2>&1 && [[ "$DRY_RUN" -eq 0 ]]; then
        "${SUDO[@]}" /usr/bin/sshd -t
    fi

    if [[ -d /etc/sv/sshd ]]; then
        RunCmd "${SUDO[@]}" ln -snf /etc/sv/sshd /var/service/sshd
        RunCmd "${SUDO[@]}" sv restart sshd || true
        LogOk "OpenSSH service (/var/service/sshd) is active."
    else
        LogWarn "/etc/sv/sshd not found (is this a Void Linux system?)."
    fi

    # Warn if running on Live ISO with default password
    if hostname 2>/dev/null | grep -qi "void-live"; then
        LogWarn "SECURITY NOTICE: You appear to be on the Void Live ISO (default password: 'voidlinux')."
        if UserConfirm "Would you like to set a new password for 'root' before exposing SSH on LAN?"; then
            RunCmd "${SUDO[@]}" passwd root
        fi
    fi
}

# ==============================================================================
# 2. OPTIONAL: INJECT SSH + ZSH INTO MOUNTED TARGET (e.g. /mnt AFTER INSTALL)
# ==============================================================================
SetupMountedTarget() {
    local mnt="$1"
    if [[ ! -d "${mnt}/etc" ]]; then
        LogErr "Target '${mnt}/etc' does not exist. Make sure your newly installed root partition is mounted at '${mnt}'."
        return 1
    fi

    echo ""
    echo "=============================================================================="
    LogInfo "Injecting OpenSSH + Zsh into target installation at '${mnt}'..."
    echo "=============================================================================="

    # Install openssh and zsh into target rootfs
    RunCmd "${SUDO[@]}" xbps-install -Sy -r "$mnt" openssh zsh git curl

    # Enable sshd service for first boot inside target
    if [[ -d "${mnt}/etc/sv/sshd" ]]; then
        RunCmd "${SUDO[@]}" ln -snf /etc/sv/sshd "${mnt}/etc/runit/runsvdir/default/sshd"
        LogOk "Enabled sshd service inside '${mnt}' for first boot."
    fi

    # Copy network resolv.conf if missing and set root shell to /bin/zsh in target
    if [[ "$DRY_RUN" -eq 0 ]]; then
        "${SUDO[@]}" chroot "$mnt" usermod -s /bin/zsh root || true
        if [[ -f /root/.zshrc && ! -f "${mnt}/root/.zshrc" ]]; then
            "${SUDO[@]}" cp -a /root/.zshrc "${mnt}/root/.zshrc"
        fi
    else
        printf "  \033[0;36m[DRY-RUN]\033[0m chroot %s usermod -s /bin/zsh root\n" "$mnt"
    fi

    LogOk "Target '${mnt}' is now pre-configured with SSH + Zsh on first boot!"
}

# ==============================================================================
# 3. DISPLAY CONNECTION SUMMARY
# ==============================================================================
PrintConnectionInfo() {
    local ip_list
    ip_list="$(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print $2 ": " a[1]}' || true)"

    echo ""
    echo "=============================================================================="
    LogOk "SSH & ZSH BOOTSTRAP READY!"
    echo "=============================================================================="
    echo "  Active Network IPs:"
    if [[ -n "$ip_list" ]]; then
        while IFS= read -r line; do
            printf "    - %s\n" "$line"
        done <<< "$ip_list"
    else
        echo "    (No active LAN IPv4 detected yet — connect via nmtui / wpa_supplicant)"
    fi
    echo ""
    echo "  Connect from another machine:"
    local first_ip
    first_ip="$(ip -4 -o addr show scope global 2>/dev/null | awk '{split($4,a,"/"); print a[1]; exit}' || echo "<VOID_IP>")"
    printf "    ssh root@%s\n" "${first_ip:-<VOID_IP>}"
    if [[ -n "${SUDO_USER:-}" ]]; then
        printf "    ssh %s@%s\n" "$SUDO_USER" "${first_ip:-<VOID_IP>}"
    fi
    echo ""
    echo "  Start Zsh immediately in this terminal:"
    echo "    exec zsh"
    echo "=============================================================================="
}

SetupCurrentSystem
if [[ -n "$TARGET_MNT" ]]; then
    SetupMountedTarget "$TARGET_MNT"
fi
PrintConnectionInfo

