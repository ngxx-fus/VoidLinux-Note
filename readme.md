# 🚀 VoidLinux BSPWM: 3-Stage Bootstrap & Dotfiles Suite (`x86_64`)

A modular, security-hardened **Void Linux (`x86_64`)** desktop environment built around **bspwm**, **sxhkd**, **polybar**, **rofi**, **dunst**, **picom**, **copyq**, and **fcitx5** — migrated and adapted for Void Linux's **`runit`** init system and **`elogind`** session manager.

---

## 📑 Table of Contents

- [Overview](#-overview)
- [Repository Structure](#-repository-structure)
- [3-Stage Installation Workflow](#-3-stage-installation-workflow)
  - [Pre-Install: Bootstrap SSH & Zsh on Live ISO (`SSHAtInstall.sh`)](#pre-install-bootstrap-ssh--zsh-on-live-iso-sshatinstallsh)
  - [Stage 0: Core System, Firmware, Drivers & Dev Libraries (`SetupStage0.sh`)](#stage-0-core-system-firmware-drivers--dev-libraries-setupstage0sh)
  - [Stage 1: Xorg, BSPWM UI Stack, CopyQ & Applications (`SetupStage1.sh`)](#stage-1-xorg-bspwm-ui-stack-copyq--applications-setupstage1sh)
  - [Stage 2: Deploy Configurations (`root/`) & Enable Runit Services (`SetupStage2.sh`)](#stage-2-deploy-configurations-root--enable-runit-services-setupstage2sh)
- [CLI Flags & Interactive Mode](#-cli-flags--interactive-mode)
- [Void Linux Adaptations (from Ubuntu/systemd)](#-void-linux-adaptations-from-ubuntusystemd)
- [Desktop Environment Layout](#-desktop-environment-layout)
- [Keybindings Cheat Sheet](#-keybindings-cheat-sheet)
- [Security & Safety Design](#-security--safety-design)

---

## 🌟 Overview

This repository provides a clean, staged workflow ("install packages first, configure second") to bootstrap a fresh **Void Linux (`x86_64`)** laptop or PC:

0. **[`SSHAtInstall.sh`](file:///home/fus/Downloads/VoidLinux-Note/SSHAtInstall.sh)** *(Optional Pre-Install / Live ISO)* — Enables `sshd` and installs `zsh` right inside the Void Linux Live ISO (or injects them directly into `/mnt` before rebooting out of `void-installer`), allowing you to install and configure Void Linux remotely over SSH with a full Zsh shell.
1. **[`SetupStage0.sh`](file:///home/fus/Downloads/VoidLinux-Note/SetupStage0.sh)** — Syncs `xbps`, enables `void-repo-nonfree` & `void-repo-multilib`, auto-detects CPU/GPU hardware (Intel/AMD microcode, `sof-firmware`, Mesa/VA-API/Vulkan drivers), and installs core system daemons, PipeWire audio, CLI tools, and `-devel` build libraries.
2. **[`SetupStage1.sh`](file:///home/fus/Downloads/VoidLinux-Note/SetupStage1.sh)** — Installs the Xorg display server, `libinput` drivers, the full **BSPWM** desktop stack (`bspwm`, `sxhkd`, `polybar`, `rofi`, `picom`, `dunst`, `feh`, `touchegg`), **CopyQ**, **Flameshot**, **Fcitx5** (Vietnamese Bamboo/Unikey), **Thunar**, fonts, themes, and daily GUI applications.
3. **[`SetupStage2.sh`](file:///home/fus/Downloads/VoidLinux-Note/SetupStage2.sh)** — Deploys the Void-ready configurations from [`root/`](file:///home/fus/Downloads/VoidLinux-Note/root) into `$HOME`, `/etc/`, and `/usr/local/bin/` based on [`PathLists.txt`](file:///home/fus/Downloads/VoidLinux-Note/PathLists.txt), configures user hardware groups, and links essential `runit` services in `/var/service/`.

---

## 🗂️ Repository Structure

```text
VoidLinux-Note/
├── SSHAtInstall.sh        # Pre-Install: Enable OpenSSH + Zsh during Live ISO or into /mnt
├── SetupStage0.sh         # Stage 0: Core packages, firmware, GPU/CPU drivers & -devel libs
├── SetupStage1.sh         # Stage 1: Xorg, BSPWM, CopyQ, Fcitx5, fonts, themes & GUI apps
├── SetupStage2.sh         # Stage 2: Restore root/ configs, user groups & runit services
├── PathLists.txt          # Manifest of managed dotfiles and system configuration paths
├── packages_manual.txt    # Reference package list from previous setup
├── readme.md              # Documentation, architecture, and keybindings guide
└── root/                  # Mirrored root filesystem tree for Void Linux
    ├── etc/
    │   ├── acpi/          # ACPI WMI & battery event handlers
    │   ├── elogind/       # Void Linux elogind power & lid-switch config (logind.conf)
    │   └── X11/xorg.conf.d/ # Touchpad libinput config (30-touchpad.conf)
    ├── home/
    │   └── fus/           # User dotfiles (.xinitrc, .zshrc, .config/bspwm, polybar, etc.)
    │       ├── .cargo/bin/xidlehook
    │       ├── .config/
    │       ├── .xinitrc
    │       └── .zshrc
    └── usr/local/bin/     # Helper binaries (betterlockscreen, skippy-xd)
```

---

## 🚀 3-Stage Installation Workflow

### Pre-Install: Bootstrap SSH & Zsh on Live ISO (`SSHAtInstall.sh`)

Run inside the Void Linux Live ISO (or immediately on first boot) to get an active OpenSSH server and Zsh shell:

```bash
# Enable SSH (with root login allowed) + Zsh on Live ISO / current system
./SSHAtInstall.sh --yes --permit-root

# After running void-installer (before rebooting), also inject SSH + Zsh into /mnt:
./SSHAtInstall.sh --yes --permit-root --mnt /mnt
```

---

### Stage 0: Core System, Firmware, Drivers & Dev Libraries (`SetupStage0.sh`)

Installs base packages, firmware, and drivers without modifying any dotfiles or services:

```bash
# Preview all Stage 0 commands safely without making changes
./SetupStage0.sh --dry-run

# Run interactively (confirm per package group: y/n/a/q)
./SetupStage0.sh

# Or install all Stage 0 package groups automatically
./SetupStage0.sh --yes
```

**Package Groups in Stage 0:**
1. **`01-XBPS-and-Repos`**: Updates `xbps` first, runs full system sync (`xbps-install -Syu`), and enables `void-repo-nonfree` + `void-repo-multilib`.
2. **`02-Firmware-and-Microcode`**: Auto-detects Intel/AMD CPU (`intel-ucode`, `linux-firmware-intel`, `linux-firmware-network`, and `sof-firmware` for Intel Sound Open Firmware audio).
3. **`03-GPU-and-Acceleration-Drivers`**: `mesa`, `mesa-dri`, `mesa-vaapi`, `mesa-vdpau`, `mesa-vulkan-intel`, `intel-video-accel`, `vulkan-loader`, `xf86-video-modesetting`.
4. **`04-System-Session-and-Power`**: `dbus`, `dbus-x11`, `elogind`, `polkit`, `lxsession` (`lxpolkit`), `acpid`, `upower`, `power-profiles-daemon`, `brightnessctl`, `lm_sensors`, `udisks2`.
5. **`05-Network-and-Bluetooth`**: `NetworkManager`, `network-manager-applet`, `bluez`, `blueman`, `rfkill`, `openssh`, `curl`, `wget`.
6. **`06-Audio-PipeWire-Stack`**: `pipewire`, `wireplumber`, `alsa-pipewire`, `libpulseaudio`, `pulseaudio-utils`, `alsa-utils`, `pamixer`, `pavucontrol`.
7. **`07-Core-CLI-and-Shell-Tools`**: `bash`, `zsh`, `dash`, `tmux`, `vim`, `neovim`, `git`, `github-cli`, `btop`, `htop`, `iotop`, `duf`, `fastfetch`, `ripgrep`, `fd`, `fzf`, `plocate`, etc.
8. **`08-Dev-Compilers-and-Toolchains`** & **`09-X11-and-System-Devel-Libraries`**: Full `base-devel`, `gcc`, `cmake`, `meson`, `ninja`, `rust`/`cargo`, `python3`, and X11/xcb/GTK/Qt6 `-devel` headers.

---

### Stage 1: Xorg, BSPWM UI Stack, CopyQ & Applications (`SetupStage1.sh`)

Installs the graphical X11 environment, window manager, clipboard manager, input method, and desktop apps:

```bash
# Preview all Stage 1 commands safely
./SetupStage1.sh --dry-run

# Run interactively (y/n/a/q)
./SetupStage1.sh

# Or install all Stage 1 package groups automatically
./SetupStage1.sh --yes
```

**Package Groups in Stage 1:**
1. **`01-Xorg-Server-and-Input-Utils`**: `xorg-minimal`, `xorg-apps`, `xorg-input-drivers`, `xf86-input-libinput`, `xinit`, `xauth`, `xrandr`, `xsetroot`, `xcape`, `xdotool`, `xclip`, `xsel`, `xdg-utils`.
2. **`02-BSPWM-Desktop-Core`**: `bspwm`, `sxhkd`, `polybar`, `rofi`, `picom`, `dunst`, `libnotify`, `feh`, `touchegg`.
3. **`03-CopyQ-Screenshot-and-Lockscreen`**: `copyq`, `flameshot`, `maim`, `scrot`, `i3lock-color`, `ImageMagick`, `bc`.
4. **`04-Fcitx5-Input-Method`**: `fcitx5`, `fcitx5-bamboo`, `fcitx5-unikey`, `fcitx5-configtool`, `fcitx5-gtk+2`, `fcitx5-gtk+3`, `fcitx5-gtk4`, `fcitx5-qt5`, `fcitx5-qt6`.
5. **`05-Terminal-Thunar-and-Themes`**: `alacritty`, `Thunar` (+ archive/volman plugins & `gvfs`), `lxappearance`, `arc-theme`, `papirus-icon-theme`, `yad`.
6. **`06-UI-and-Icon-Fonts`**: `font-jetbrains-mono-ttf`, `font-awesome` (4/5/6), `nerd-fonts-symbols-ttf`, `dejavu-fonts-ttf`, `liberation-fonts-ttf`, `noto-fonts-*`.
7. **`07-Desktop-and-Media-Apps`**: `firefox`, `chromium`, `vlc`, `ffmpeg`, `obs`, `xournalpp`, `gnome-calculator`, `gsimplecal`, `cheese`.

---

### Stage 2: Deploy Configurations (`root/`) & Enable Runit Services (`SetupStage2.sh`)

Deploys the curated files in [`root/`](file:///home/fus/Downloads/VoidLinux-Note/root) onto your Void Linux machine, adds your user to required hardware groups, and enables `runit` services:

```bash
# Preview all file deployments, group changes, and service symlinks
./SetupStage2.sh --dry-run

# Interactive deployment and service activation
./SetupStage2.sh

# Non-interactive full deployment
./SetupStage2.sh --yes
```

After running `SetupStage2.sh`, start your graphical session from TTY:

```bash
startx
```

---

## ⚙️ CLI Flags & Interactive Mode

All three scripts (`SetupStage0.sh`, `SetupStage1.sh`, `SetupStage2.sh`) share a consistent CLI interface:

| Flag | Long Flag | Description |
| :--- | :--- | :--- |
| `-y` | `--yes`, `-a`, `--all` | Run non-interactively; automatically confirm all operations |
| `-n` | `--dry-run` | Preview operations without modifying packages, files, or services |
| `-h` | `--help` | Display usage instructions and options |
| — | `--skip-dotfiles` | *(Stage 2 only)* Skip copying dotfiles from `root/` |
| — | `--skip-services` | *(Stage 2 only)* Skip user group & `/var/service` setup |

Interactive prompt options (`[y/n/a/q]`):
- **`y` (Yes)**: Execute the current group/item.
- **`n` (No)**: Skip the current group/item.
- **`a` (All)**: Execute the current item and all remaining items automatically.
- **`q` (Quit)**: Safely abort and clean up lockfiles immediately.

---

## 🔄 Void Linux Adaptations (from Ubuntu/systemd)

The [`root/`](file:///home/fus/Downloads/VoidLinux-Note/root) tree and [`PathLists.txt`](file:///home/fus/Downloads/VoidLinux-Note/PathLists.txt) have been cleaned and adapted specifically for Void Linux:

1. **`elogind` instead of `systemd-logind`**:
   - Replaced `systemctl suspend`, `systemctl reboot`, and `systemctl poweroff` with `loginctl suspend`, `loginctl reboot`, and `loginctl poweroff` in [`bspwmrc`](file:///home/fus/Downloads/VoidLinux-Note/root/home/fus/.config/bspwm/bspwmrc), [`Helper-Power`](file:///home/fus/Downloads/VoidLinux-Note/root/home/fus/.config/bspwm/scripts/Helper-Power), and [`betterlockscreen`](file:///home/fus/Downloads/VoidLinux-Note/root/usr/local/bin/betterlockscreen).
   - Replaced `/etc/systemd/logind.conf` with [`/etc/elogind/logind.conf`](file:///home/fus/Downloads/VoidLinux-Note/root/etc/elogind/logind.conf) (ignoring lid switch when docked to external monitors).
2. **`PipeWire` Auto-Start in `bspwmrc`**:
   - Since Void Linux uses `runit` rather than `systemd --user` socket activation, [`bspwmrc`](file:///home/fus/Downloads/VoidLinux-Note/root/home/fus/.config/bspwm/bspwmrc) ensures `pipewire`, `pipewire-pulse`, and `wireplumber` are launched idempotently on login.
3. **X11 Session Entrypoint (`~/.xinitrc`)**:
   - Added [`~/.xinitrc`](file:///home/fus/Downloads/VoidLinux-Note/root/home/fus/.xinitrc) to export `fcitx` input method variables, initialize cursor/resources, and start `bspwm` inside `dbus-run-session`.
4. **Removed Legacy Ubuntu/Openbox Remnants**:
   - Removed broken Ubuntu PPA symlink (`/usr/local/bin/howdy`), unused Openbox schemas (`obmenu-generator`, `obmenu`, `.themes/Breeze-ob-custom`), and updated [`/etc/acpi/handler.sh`](file:///home/fus/Downloads/VoidLinux-Note/root/etc/acpi/handler.sh) to call [`Helper-ChangeKeyboardBrightness`](file:///home/fus/Downloads/VoidLinux-Note/root/home/fus/.config/bspwm/scripts/Helper-ChangeKeyboardBrightness).

---

## 📂 Desktop Environment Layout

```text
~/.config/bspwm/
├── bspwmrc                      # Main initialization script, PipeWire/daemon autostart & window rules
├── alacritty/alacritty.yml      # Alacritty terminal emulator configuration
├── dunst/dunstrc                # Notification daemon configuration (with OSD progress bars)
├── picom/picom.conf             # X11 compositor (opacity, shadows, fading)
├── polybar/                     # Modular status bar
│   ├── config.ini               # Bar modules (workspaces, audio, backlight, battery, bluetooth, fcitx5)
│   └── colors.ini               # Color palette
├── rofi/                        # Application launcher & modal menus
│   ├── config.rasi              # Universe launcher configuration
│   ├── controlpanel.rasi        # Quick control panel & power menu theme
│   ├── keybinds.rasi            # Keybindings cheat sheet popup
│   └── popup.rasi               # Shared modal theme
├── scripts/                     # Helper & automation scripts
│   ├── Helper-ChangeBrightness  # Screen brightness control with Dunst OSD
│   ├── Helper-ChangeKeyboardBrightness # Keyboard backlight control with Dunst OSD
│   ├── Helper-ChangeVolume      # Audio volume control with Dunst OSD
│   ├── Helper-CpuTemp           # Combined CPU usage & package temperature for Polybar
│   ├── Helper-DisplaySwitching  # Multi-monitor profile switcher (PC only, Duplicate, Extend, Second only)
│   ├── Helper-Help              # Displays keybinding cheat sheet via Rofi
│   ├── Helper-Power             # Session & power profiles menu (Performance/Power-save, Lock, Suspend, Reboot, Shutdown)
│   ├── Helper-ToggleTouchpad    # Touchpad toggle notification helper
│   ├── Service-Background       # Wallpaper slideshow & betterlockscreen blur cache manager
│   └── Service-Polybar          # Multi-monitor Polybar launcher
├── skippy-xd/skippy-xd.rc       # Exposé-style visual window switcher configuration
├── sxhkd/sxhkdrc                # Simple X Hotkey Daemon keybindings
└── wallpaper/                   # Curated FHD & Ultrawide (3440x1440) wallpapers
```

---

## ⚡ Keybindings Cheat Sheet

Modifier Key: **`Super`** (Windows key).

### 🖥️ Applications & Utilities
| Shortcut | Action | Command / Target |
| :--- | :--- | :--- |
| `Super + Enter` / `Super + r` | Open Terminal | `alacritty` |
| `Alt + Space` | Application Launcher (Universe) | `rofi -show combi` |
| `Super + e` | File Manager | `thunar` |
| `Super + v` | Clipboard History Manager | `copyq toggle` |
| `Super + l` | Lock Screen | `betterlockscreen -l blur` |
| `Super + Tab` | Visual Window Switcher (Exposé) | `skippy-xd --toggle` |
| `Alt + Tab` / `Alt + Shift + Tab` | Focus next / previous window | `bspc node -f next/prev.local.!hidden.window` |
| `Super + Space` | Toggle Vietnamese Input Method | `fcitx5-remote -t` |
| `Super + p` | Display Switching Menu | `Helper-DisplaySwitching` |
| `Super + x` | Power & Control Menu | `Helper-Power` (`loginctl` & `powerprofilesctl`) |
| `Super + /` | Hotkey Cheat Sheet | `Helper-Help` |
| `Super + Esc` | Reload Hotkeys | `pkill -USR1 -x sxhkd` |

### 🪟 Window Management
| Shortcut | Action |
| :--- | :--- |
| `Super + q` / `Super + w` | Close focused window (`bspc node -c`) |
| `Super + Shift + w` | Force kill window (`bspc node -k`) |
| `Super + f` | Toggle Fullscreen state |
| `Super + s` | Toggle between Floating and Tiled states |
| `Super + m` | Toggle between Tiled and Monocle (Maximized) layout |
| `Super + {Left, Down, Up, Right}` | Directional window focus (Arrow keys) |
| `Super + {h, j, k, l}` | Directional window focus (Vim keys) |
| `Super + Shift + {Arrows / hjkl}` | Swap focused window with neighbor |
| `Super + Ctrl + {Arrows}` | Move floating window coordinates |
| `Super + Alt + {h, j, k, l}` | Expand window size |
| `Super + Alt + Shift + {h, j, k, l}` | Contract window size |

### 🧭 Workspaces & Multi-Monitor
| Shortcut | Action |
| :--- | :--- |
| `Super + [1-9]` | Switch to Workspace 1–9 on focused monitor |
| `Super + Shift + [1-9]` | Send focused window to Workspace 1–9 |
| `Ctrl + Alt + Left / Right` | Cycle previous / next desktop |
| `Super + comma` / `Super + period` | Focus previous / next physical monitor |
| `Super + Ctrl + Shift + {Arrows}` | Send window to directional monitor |

### 🔊 Media & Hardware Controls
| Shortcut | Action |
| :--- | :--- |
| `XF86AudioRaiseVolume` / `Super + F12` | Volume Up (with Dunst OSD) |
| `XF86AudioLowerVolume` / `Super + F11` | Volume Down (with Dunst OSD) |
| `XF86AudioMute` / `Super + F10` | Mute / Unmute Audio |
| `XF86AudioMicMute` / `XF86Launch5` | Mute / Unmute Microphone |
| `XF86MonBrightnessUp / Down` | Screen Brightness Control |
| `XF86KbdBrightnessUp / Down` | Keyboard Backlight Control |
| `Print` | Fullscreen Screenshot (`flameshot full`) |
| `Super + Shift + s` | Interactive Area Screenshot (`flameshot gui`) |

---

## 🔒 Security & Safety Design

- **Strict Execution Guards**: All scripts enforce `set -euo pipefail`, `umask 022`, symlink-safe PID lockfiles (`/tmp/void_setup_stage*.lock`), and owner-restricted log files (`0600` at `/tmp/void_setup_stage*.log`).
- **Official Repositories Only**: Packages are installed strictly via Void Linux's official `xbps-install` repositories with per-package fallback if a mirror or package is temporarily unavailable.
- **Privilege & Ownership Isolation**:
  - User files deployed into `$HOME` are assigned `$USER:$USER` ownership and dynamically adapt paths if restored under a different username.
  - System files deployed into `/etc/` and `/usr/local/bin/` are assigned `root:root` ownership with `0755`/`0644` permissions.