#!/usr/bin/env bash
# ==============================================================================
# SetupStage2.sh
# Stage 2: Deploy Configurations (root/ -> Void Linux), User Groups & Runit Services
# Target : Void Linux (x86_64 Laptop/PC - BSPWM Desktop Environment)
# ==============================================================================

set -euo pipefail
IFS=$' \t\n'
umask 022

# ==============================================================================
# SECURITY & RUNTIME CONSTANTS
# ==============================================================================
readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]:-$0}")"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
readonly LIST_PATHS="${SCRIPT_DIR}/PathLists.txt"
readonly DIR_ROOT="${SCRIPT_DIR}/root"
readonly LOCK_FILE="/tmp/void_setup_stage2.lock"
readonly LOG_FILE="/tmp/void_setup_stage2_$(date +%Y%m%d_%H%M%S).log"

CONFIRM_ALL=0
DRY_RUN=0
SKIP_DOTFILES=0
SKIP_SERVICES=0

# Resolve target user and home directory (even if invoked via sudo)
readonly TARGET_USER="${SUDO_USER:-${USER:-$(id -un)}}"
readonly TARGET_GROUP="$(id -gn "$TARGET_USER" 2>/dev/null || echo "$TARGET_USER")"
readonly TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6 || echo "/home/${TARGET_USER}")"

COUNT_RESTORED=0
COUNT_SKIPPED=0
COUNT_MISSING=0
COUNT_SERVICES=0

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

Stage 2 Void Linux Configuration & Service Deployment:
  1. Deploys dotfiles and system configs from '${DIR_ROOT}' to local Void Linux
     based on 'PathLists.txt' (with automatic user home mapping and permission hardening).
  2. Adds user '${TARGET_USER}' to required hardware/session groups.
  3. Enables essential Void Linux runit services in /var/service/.

Options:
  -y, --yes, -a, --all    Confirm all operations automatically (non-interactive)
  -n, --dry-run           Preview all actions without modifying any files or services
  --skip-dotfiles         Skip deploying files from root/
  --skip-services         Skip user group & runit service configuration
  -h, --help              Show this help message and exit

Interactive Choices:
  [y] Yes  - Apply this item
  [n] No   - Skip this item
  [a] All  - Apply this and all subsequent items automatically
  [q] Quit - Abort script safely
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
        --skip-dotfiles)
            SKIP_DOTFILES=1
            ;;
        --skip-services)
            SKIP_SERVICES=1
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
# PRIVILEGE & ENVIRONMENT HELPERS
# ==============================================================================
VerifyPrerequisites() {
    if [[ ! -f "$LIST_PATHS" ]]; then
        LogErr "Path list file not found: $LIST_PATHS"
        exit 1
    fi
    if [[ ! -d "$DIR_ROOT" ]]; then
        LogErr "Backup root directory not found: $DIR_ROOT"
        exit 1
    fi

    if [[ "$DRY_RUN" -eq 0 ]]; then
        if [[ "$EUID" -eq 0 ]]; then
            SUDO_CMD=()
        elif command -v sudo >/dev/null 2>&1; then
            SUDO_CMD=(sudo)
            LogInfo "Validating sudo credentials..."
            sudo -v
        else
            LogErr "Neither running as root nor is 'sudo' available."
            exit 1
        fi
    else
        SUDO_CMD=(sudo)
        LogInfo "DRY-RUN mode enabled: No files, groups, or services will be modified."
    fi
}

# Detect the backed-up username inside root/home/<user>
DetectRepoHomeRel() {
    if [[ -d "${DIR_ROOT}${TARGET_HOME}" ]]; then
        echo "${TARGET_HOME#/}"
        return 0
    fi
    if [[ -d "${DIR_ROOT}/home" ]]; then
        local first_user_dir
        first_user_dir="$(find "${DIR_ROOT}/home" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -n 1 || true)"
        if [[ -n "$first_user_dir" ]]; then
            echo "home/$(basename "$first_user_dir")"
            return 0
        fi
    fi
    echo "${TARGET_HOME#/}"
}

# ==============================================================================
# PHASE 1: DEPLOY DOTFILES & SYSTEM CONFIGS FROM root/
# ==============================================================================
RestoreItem() {
    local src="$1"
    local dst="$2"
    local is_dir="$3"

    local dst_clean="${dst%/}"
    local parent_dir
    parent_dir="$(dirname "$dst_clean")"

    local is_user_path=0
    if [[ "$dst_clean" == "$TARGET_HOME" || "$dst_clean" == "$TARGET_HOME/"* ]]; then
        is_user_path=1
    fi

    if [[ "$DRY_RUN" -eq 1 ]]; then
        if [[ "$is_dir" -eq 1 ]]; then
            printf "  \033[0;36m[DRY-RUN]\033[0m Sync directory: '%s/.' -> '%s/'\n" "${src%/}" "$dst_clean"
        else
            printf "  \033[0;36m[DRY-RUN]\033[0m Copy file     : '%s' -> '%s'\n" "$src" "$dst_clean"
        fi
        return 0
    fi

    if [[ "$is_user_path" -eq 1 ]]; then
        mkdir -p "$parent_dir"
        if [[ "$is_dir" -eq 1 ]]; then
            mkdir -p "$dst_clean"
            cp -a "${src%/}/." "$dst_clean/"
        else
            cp -a "$src" "$dst_clean"
        fi
        # Ensure proper ownership if script was invoked with sudo
        if [[ "$EUID" -eq 0 ]]; then
            chown -R "${TARGET_USER}:${TARGET_GROUP}" "$dst_clean"
        fi
        # Rewrite hardcoded /home/fus paths if deployed to a different username
        if [[ "$TARGET_HOME" != "/home/fus" ]]; then
            find "$dst_clean" -type f -exec grep -Iq "/home/fus" {} + -exec \
                sed -i "s|/home/fus|${TARGET_HOME}|g" {} + 2>/dev/null || true
        fi
    else
        "${SUDO_CMD[@]}" mkdir -p "$parent_dir"
        if [[ "$is_dir" -eq 1 ]]; then
            "${SUDO_CMD[@]}" mkdir -p "$dst_clean"
            "${SUDO_CMD[@]}" cp -a "${src%/}/." "$dst_clean/"
        else
            "${SUDO_CMD[@]}" cp -a "$src" "$dst_clean"
        fi
        "${SUDO_CMD[@]}" chown -R root:root "$dst_clean"

        # Enforce safe permissions on system binaries & scripts
        if [[ "$dst_clean" == /usr/local/bin/* || "$dst_clean" == /etc/acpi/handler.sh ]]; then
            "${SUDO_CMD[@]}" chmod 755 "$dst_clean"
        elif [[ "$dst_clean" == /etc/acpi ]]; then
            "${SUDO_CMD[@]}" chmod 755 "/etc/acpi/handler.sh" 2>/dev/null || true
        fi
    fi

    LogOk "Deployed: $dst"
}

DeployDotfilesPhase() {
    echo ""
    echo "=============================================================================="
    LogInfo "Phase 1: Deploying Dotfiles & System Configurations from root/"
    echo "=============================================================================="

    local repo_home_rel
    repo_home_rel="$(DetectRepoHomeRel)"

    while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
        local line
        line="$(echo "$raw_line" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        [[ -z "$line" || "$line" == \#* ]] && continue

        local is_dir=0
        [[ "$line" == */ ]] && is_dir=1

        local target_path="$line"
        if [[ "$target_path" == "~"* ]]; then
            target_path="${TARGET_HOME}${target_path#\~}"
        elif [[ "$target_path" =~ ^/home/[^/]+(/.*)?$ ]]; then
            local sub_path="${target_path#/home/*/}"
            if [[ "$sub_path" == "$target_path" ]]; then
                target_path="$TARGET_HOME"
            else
                target_path="${TARGET_HOME}/${sub_path}"
            fi
        fi

        local rel_path="${target_path#/}"
        rel_path="${rel_path%/}"

        local src_path=""
        if [[ "$target_path" == "$TARGET_HOME" || "$target_path" == "$TARGET_HOME/"* ]]; then
            local home_sub="${target_path#"$TARGET_HOME"}"
            home_sub="${home_sub#/}"
            home_sub="${home_sub%/}"
            if [[ -n "$home_sub" ]]; then
                src_path="${DIR_ROOT}/${repo_home_rel}/${home_sub}"
            else
                src_path="${DIR_ROOT}/${repo_home_rel}"
            fi
        else
            src_path="${DIR_ROOT}/${rel_path}"
        fi

        if [[ ! -e "$src_path" && ! -L "$src_path" ]]; then
            LogWarn "Source not found in root/, skipping: $src_path"
            COUNT_MISSING=$((COUNT_MISSING + 1))
            continue
        fi

        local type_label="FILE"
        [[ -d "$src_path" && ! -L "$src_path" ]] && is_dir=1
        [[ "$is_dir" -eq 1 ]] && type_label="DIR "

        local state_label="NEW"
        local dst_check="${target_path%/}"
        [[ -e "$dst_check" || -L "$dst_check" ]] && state_label="EXISTS - WILL UPDATE"

        printf "\n[%s] Source : %s\n" "$type_label" "$src_path"
        printf "       Target : %s (%s)\n" "$target_path" "$state_label"

        if UserConfirmYNA "--> Deploy '${target_path}'?"; then
            RestoreItem "$src_path" "$target_path" "$is_dir"
            COUNT_RESTORED=$((COUNT_RESTORED + 1))
        else
            LogWarn "Skipped: $target_path"
            COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
        fi
    done < "$LIST_PATHS"

    # Ensure executable permissions on key user scripts
    if [[ "$DRY_RUN" -eq 0 ]]; then
        chmod +x "${TARGET_HOME}/.xinitrc" 2>/dev/null || true
        chmod +x "${TARGET_HOME}/.config/bspwm/bspwmrc" 2>/dev/null || true
        chmod +x "${TARGET_HOME}/.config/bspwm/scripts/"* 2>/dev/null || true
        chmod +x "${TARGET_HOME}/.config/polybar/scripts/"* 2>/dev/null || true
        chmod +x "${TARGET_HOME}/.cargo/bin/xidlehook" 2>/dev/null || true
    fi
}

# ==============================================================================
# PHASE 2: USER GROUPS & VOID LINUX RUNIT SERVICES
# ==============================================================================
ConfigureGroupsAndServicesPhase() {
    echo ""
    echo "=============================================================================="
    LogInfo "Phase 2: User Groups & Void Linux Runit Services (/var/service)"
    echo "=============================================================================="

    # 1. Add user to standard Void Linux desktop/hardware groups
    local -a desired_groups=(wheel audio video input network bluetooth storage optical plugdev)
    local -a valid_groups=()

    for grp in "${desired_groups[@]}"; do
        if getent group "$grp" >/dev/null 2>&1; then
            valid_groups+=("$grp")
        fi
    done

    if [[ "${#valid_groups[@]}" -gt 0 ]]; then
        local group_csv
        group_csv="$(IFS=,; echo "${valid_groups[*]}")"
        if UserConfirmYNA "Add user '${TARGET_USER}' to hardware/session groups (${group_csv})?"; then
            if [[ "$DRY_RUN" -eq 1 ]]; then
                printf "  \033[0;36m[DRY-RUN]\033[0m %s usermod -aG %s %s\n" "${SUDO_CMD[*]}" "$group_csv" "$TARGET_USER"
            else
                "${SUDO_CMD[@]}" usermod -aG "$group_csv" "$TARGET_USER"
                LogOk "Added '${TARGET_USER}' to groups: ${group_csv}"
            fi
        fi
    fi

    # 2. Enable essential Void Linux runit services in /var/service
    local -a core_services=(
        dbus
        elogind
        polkitd
        NetworkManager
        bluetoothd
        acpid
        power-profiles-daemon
        touchegg
    )

    echo ""
    LogInfo "Checking Void Linux runit services (/etc/sv -> /var/service)..."
    if UserConfirmYNA "Enable core desktop runit services (${core_services[*]})?"; then
        # Prevent NetworkManager conflict with standalone dhcpcd/wpa_supplicant
        for conflict_svc in dhcpcd wpa_supplicant; do
            if [[ -L "/var/service/${conflict_svc}" ]]; then
                if [[ "$DRY_RUN" -eq 1 ]]; then
                    printf "  \033[0;36m[DRY-RUN]\033[0m Remove conflicting service symlink: /var/service/%s\n" "$conflict_svc"
                else
                    "${SUDO_CMD[@]}" rm -f "/var/service/${conflict_svc}"
                    LogWarn "Disabled conflicting service '/var/service/${conflict_svc}' in favor of NetworkManager."
                fi
            fi
        done

        for svc in "${core_services[@]}"; do
            if [[ "$DRY_RUN" -eq 1 ]]; then
                printf "  \033[0;36m[DRY-RUN]\033[0m ln -snf /etc/sv/%s /var/service/%s\n" "$svc" "$svc"
                COUNT_SERVICES=$((COUNT_SERVICES + 1))
                continue
            fi

            if [[ -d "/etc/sv/${svc}" ]]; then
                if [[ ! -L "/var/service/${svc}" && ! -e "/var/service/${svc}" ]]; then
                    "${SUDO_CMD[@]}" ln -s "/etc/sv/${svc}" "/var/service/${svc}"
                    LogOk "Enabled runit service: ${svc}"
                else
                    LogInfo "Service already enabled: ${svc}"
                fi
                COUNT_SERVICES=$((COUNT_SERVICES + 1))
            else
                LogWarn "Service directory '/etc/sv/${svc}' not found (install package first)."
            fi
        done
    fi
}

# ==============================================================================
# MAIN EXECUTION
# ==============================================================================
RunStage2() {
    InitSecurityAndLog
    VerifyPrerequisites

    echo "=============================================================================="
    LogInfo "Void Linux Stage 2 Deployment (Target User: ${TARGET_USER}, Home: ${TARGET_HOME})"
    LogInfo "Log File: ${LOG_FILE}"
    echo "=============================================================================="

    if [[ "$SKIP_DOTFILES" -eq 0 ]]; then
        DeployDotfilesPhase
    else
        LogWarn "Skipped Phase 1 (Dotfiles deployment) via --skip-dotfiles."
    fi

    if [[ "$SKIP_SERVICES" -eq 0 ]]; then
        ConfigureGroupsAndServicesPhase
    else
        LogWarn "Skipped Phase 2 (User groups & runit services) via --skip-services."
    fi

    echo ""
    echo "=============================================================================="
    LogOk "SetupStage2.sh completed!"
    echo "=============================================================================="
    printf "  Log File          : %s\n" "$LOG_FILE"
    printf "  Deployed Items    : %d\n" "$COUNT_RESTORED"
    printf "  Skipped Items     : %d\n" "$COUNT_SKIPPED"
    printf "  Missing Sources   : %d\n" "$COUNT_MISSING"
    printf "  Services Checked  : %d\n" "$COUNT_SERVICES"
    echo "=============================================================================="
    LogInfo "To start BSPWM on Void Linux, log in as '${TARGET_USER}' and run: startx"
}

RunStage2
