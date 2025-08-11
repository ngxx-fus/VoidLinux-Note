# Installaltions

## HW (Hardware) repair

- USB (>=4GB).
- Live-image [https://voidlinux.org/download/](https://voidlinux.org/download/).
- Linux OS (I have installed VoidLinux from UBUNTU).
- USB Windows Installation (For Failed Install Attempts).

## Prepare Installation Media

* SOURCE: [Prepare Installation Media](https://docs.voidlinux.org/installation/live-images/prep.html)

(This part just make a USB LIVE IMAGE)

## Boot from USB LIVE-IMAGE 

### BASH

Void Linux installation only provides a command-line interface (CLI). For a more comfortable experience, you can use `Bash` by typing `bash` in the shell.

### Void-Installer

run `void-installer` to start install VoidLinux.

### Parition notes

SOURCE: [https://docs.voidlinux.org/installation/live-images/partitions.html](https://docs.voidlinux.org/installation/live-images/partitions.html)

This is your free disk:

    [-----------------------------------------]

My recommend:

    [--EFI:250MB---|--SWAP:4GB--|--ROOT(/)----]

### To be cont. :>

# THIS REPO

Back-up tree:

```
etc
├── acpi
│   └── handler.sh
├── dunst
│   └── dunstrc
└── sv
    ├── MyService0
    │   ├── MyService0
    │   ├── run
    │   └── supervise
    └── MyService1
        ├── MyService1
        ├── run
        └── supervise
home
└── fus
    ├── .backup.sh
    ├── .config
    │   ├── fcitx
    │   ├── fcitx5
    │   └── nvim
    ├── .display
    │   ├── dmenu
    │   ├── dwm
    │   └── dwmblocks
    ├── .fus
    │   ├── .BG
    │   ├── .data_exchange
    │   ├── .fus
    │   ├── alias
    │   ├── brightness_control.sh
    │   ├── capture-dbus-all.sh
    │   ├── disable_built_in_keyboard.sh
    │   ├── dwm-status.sh
    │   ├── get_battery_level.sh
    │   ├── get_wifi.sh
    │   ├── init_display.sh
    │   ├── internet_check.sh
    │   ├── monitor_mode
    │   ├── mount_external_ssd.sh
    │   ├── mount_sdcard.sh
    │   ├── prt_sc.sh
    │   ├── rofi_filebrowser.sh
    │   ├── screenjoin.sh
    │   ├── setup_background.sh
    │   ├── setup_wifi.sh
    │   ├── shell_utils.sh
    │   ├── toggle_display.sh
    │   ├── update_dwm.sh
    │   └── volume_control.sh
    ├── .ngxxfus.init.system.sh
    ├── .oh-my-zsh
    │   └── themes
    ├── .xinitrc
    ├── .zprofile
    └── .zshrc
usr
└── share
    └── fonts
        ├── NerdFonts
        ├── TTF
        ├── X11
        ├── fus
        ├── noto
        └── noto-emoji
```

# VoidLinux NOTE - Right after the first boot

## Utils & Tools

Some tools and utils u need to install.

```Zsh
#!/bin/sh
# =============================================================================
# Essential system tools
# =============================================================================
# btop: modern resource monitor with mouse support and beautiful TUI (like htop but better)
sudo xbps-install -Sy btop
# upower: provides battery and power statistics for laptops; used by status bars like dwmblocks
sudo xbps-install -Sy upower
# dbus: essential message bus system for communication between desktop apps and services
sudo xbps-install -Sy dbus
# elogind: manages user sessions and permissions (needed for shutdown, suspend, logout in DWM)
sudo xbps-install -Sy elogind
# udisks2: allows safe mounting/unmounting of USB drives and disks; needed by GUI file managers
sudo xbps-install -Sy udisks2
# acpid: listens to ACPI events (lid close, power button); used for laptop power handling
sudo xbps-install -Sy acpid
# xclip: access X11 clipboard from terminal (used in screenshot scripts, copy-paste from CLI)
sudo xbps-install -Sy xclip
# xdotool: simulate keyboard and mouse input, window movement, and other X11 actions
sudo xbps-install -Sy xdotool
# maim: fast screenshot tool (like `scrot`, supports selection and automation with `xdotool`)
# scrot: simple screenshot tool (less modern but widely supported and scriptable)
sudo xbps-install -Sy maim scrot
# NetworkManager: universal network configuration daemon; works with `nmtui`, `nmcli`, and GUIs
sudo xbps-install -Sy NetworkManager
# =============================================================================
# UI & appearance tools
# =============================================================================
# dunst: lightweight and configurable notification daemon (used by `notify-send`)
sudo xbps-install -Sy dunst
# feh: fast image viewer and wallpaper setter (used to set backgrounds in `.xinitrc`)
sudo xbps-install -Sy feh
# picom: compositor for X11 to enable transparency, shadows, fading, and VSync (essential for eye-candy)
sudo xbps-install -Sy picom
# fastfetch: minimal and blazing-fast system info fetcher (alternative to neofetch)
sudo xbps-install -Sy fastfetch
# xdg-utils: desktop integration tools like `xdg-open` (used to open files/URLs with default apps)
sudo xbps-install -Sy xdg-utils
# =============================================================================
# Development tools
# =============================================================================
# gcc, make, autoconf: core tools for compiling C/C++ programs and building most open-source projects
sudo xbps-install -Sy gcc make autoconf
# ripgrep (rg): blazing-fast search tool (like grep, but recursive, respects .gitignore, and faster)
sudo xbps-install -Sy ripgrep
# git: distributed version control system; essential for downloading source code (like suckless)
sudo xbps-install -Sy git
# gh-cli: GitHub CLI to interact with GitHub repositories, issues, pull requests directly from terminal
sudo xbps-install -Sy gh-cli
# =============================================================================
# Internet tools
# =============================================================================
# curl: flexible tool to make HTTP requests, download files, or interact with APIs (used everywhere)
sudo xbps-install -Sy curl
# firefox: full-featured web browser; replace with chromium or other if preferred
sudo xbps-install -Sy firefox
# =============================================================================
# Terminal emulator
# =============================================================================
# alacritty: GPU-accelerated terminal emulator (fast, minimal, with modern rendering)
sudo xbps-install -Sy alacritty
# FONT
sudo xbps-install -Sy liberation-fonts-ttf nerd-fonts-ttf
```

## Zsh/Oh-my-zsh

ZSH is modern shell that save your time in your work; oh-my-zsh help your Terminal look prety with some helpful plugins.

### Install ZSH

```Bash
sudo xbps-install -Sy xbps  # At 1st time (1st boot of VoidLinux)
sudo xbps-install -Suy      # Update system, repo (for long-time not update)
sudo xbps-install -Sy zsh   # Install zsh
```

### Install OH-MY-ZSH

**DEP**: curl

```Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

My custom them (just edit default theme):

```Zsh
PROMPT='%{$fg_bold[white]%}%n@%m%{$reset_color%} %(?:%{$fg_bold[green]%}%c:%{$fg_bold[red]%}%c) %{$reset_color%}$(git_prompt_info)
%{$fg_bold[cyan]%}➜ %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
```

Preview:

![alt text](imgs/image.png)

## Fater with Alias 

You should use aliases to speed up your work in the CLI. E.g:

```Zsh
##### -l for more info 
##### -a for all file (includes hidden files)
##### -t time order
####  -C List files in columns,
####  -F marking types (-F, e.g., / for dirs, * for executables)
alias ll="ls -CFlta"
alias la="ls -CFat"
alias l='ls -CF'
##### quick install app
alias s="sudo xbps-install -S"
alias i="sudo xbps-install -Sy"
alias u="sudo xbps-install -Suy"
alias r="sudo xbps-remove -y"
alias q="sudo xbps-query -Rs"
##### quick directory jump 
alias downloads='cd ~/Downloads'
alias desktop='cd ~/Desktop'
alias tmp='cd /tmp'
alias desktop="cd ~/Desktop"
##### git
alias clone='git clone'
alias push='git push'
alias addall='git add -A'
alias commit='git commit'
alias commitmsg='git commit -m '
##### quick edit zshrc
alias zshrc="nvim ~/.zshrc"
```

P/S: My [.zshrc](home/fus/.zshrc) and my [shell_utils.sh](home/fus/.fus/shell_utils.sh)

```Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

source /home/fus/.fus/shell_utils.sh
source /home/fus/.fus/alias
```

# VoidLinux/DWM NOTE - Right after the first boot

## My words

I have make `.Display` directory to store DWM, ST, DWM-Blocks.

```Bash
.Display
├── dmenu           # Search, Start app
├── dwm             # Window manager
├── dwmblocks       # Manage status bar
└── st              # Simple Terminal (Stuck :v, it have change to `alacritty`)
```

## Xorg

Xorg (or X.Org Server) is the open-source implementation of the X Window System, which provides the graphical display layer on Unix-like operating systems (Linux, BSD, etc.).

```Zsh
i xorg xinit xrandr
```

**DRIVER:**
```Zsh
i xf86-video-intel
```

**xinitrc:**
```Zsh

# GLOBAL VARS #################################################################
export BROWSER=firefox
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export ROFI_PNG_OUTPUT=/home/fus/Pictures/Rofi-Captures.jpg
export _HDMI=$(xrandr | grep -E '^HDMI[-0-9]* connected' | awk '{print $1}')
export _eDP=$(xrandr | grep -E '^eDP[-0-9]* connected' | awk '{print $1}')
# START-UP APP ################################################################
exec /usr/bin/picom --backend glx                       					&
exec /usr/local/bin/dwmblocks                           					&
exec /home/fus/.fus/init_display.sh                     					&
exec /home/fus/.fus/setup_background.sh                 					&
exec /home/fus/.fus/disable_built_in_keyboard.sh        					&
exec /usr/bin/fcitx5                                                        &
# DWM #########################################################################
exec dwm

```

## DWM

`dwm` is a dynamic window manager for X. It supports tiled, monocle, and floating layouts, all of which can be switched dynamically. Any configuration changes require recompiling the source.

### Dependencies

```Zsh
i git make gcc pkg-config libX11-devel libXft-devel libXinerama-devel
```

### Clone from Github

```Zsh
git clone https://github.com/Digital-Chaos/dwm.git
```

### Build & Install

```Zsh
cd dwm
make
sudo install
```

### Sound/Brightness noti

I found that all `acpi` signals is handle by [handler.sh](etc/acpi/handler.sh). You can set noti by using xsetroot. E.g:

```Zsh
write_noti() {
    local msg="$*"
    su - fus -c "DISPLAY=:0 xsetroot -name '$msg'" &
}
```

## DWM-Block

Same with DWM, clone, edit, build, install (copy). But i found a little bug on Makefile, blocks.def.h will copy and rename to blocks.h, but make clean not remove old blocks.h, hence new config is not applied.

```Zsh
git clone https://github.com/torrinfail/dwmblocks.git
cd dwmblocks
make
sudo make install
```
**FIX Makefile (OLD)**
```Makefile
blocks.h:
	cp blocks.def.h $@

clean:
	rm -f *.o *.gch dwmblocks
```
**FIX Makefile (NEW)**
```Makefile
blocks.h:
	cp blocks.def.h $@

clean:
	rm -f *.o *.gch dwmblocks blocks.h
```

P/S: DWMBLOCKS-blocks.def.h

```
static const Block blocks[] = {
    /* Icon   */    /* Command */                                                                                      /* Interval */    /* Signal */
    { "   ",      "top -bn1 | awk '/^%Cpu/ { printf \"%.1f%%\\n\", 100 - $8 }'",                                      1,              0 },
    { "   ",      "free -h | awk '/^Mem/ { print $3 }' | sed 's/i//g'",                                               1,              0 },
    { " 󰂑  ",      "echo \"$(cat /sys/class/power_supply/BAT0/capacity)%\"",                                          15,             0 },
    { " 󰥔  ",      "date '+%H:%M:%S'",                                                                                1,              0 },
    { "   ",      "date '+%d:%m:%Y'",                                                                                1,              0 },
};
```

## Build & Install DWM, DWMBlocks, ST, DMENU

I have written a script - [update_dwm.sh](home/fus/.fus/update_dwm.sh) build and install DWM, DWM-BLOCKS, ST, DMENU.

## NetworkManager

It's a command-line tool used to control and monitor NetworkManager, a system service that manages network connections.

### Install NetworkManager

```Zsh
sudo xbps-install -Sy NetworkManager
```

### Enable and Start service

```Zsh
sudo ln -s /etc/sv/NetworkManager /var/service
```

### Check service

```Zsh
sudo sv status NetworkManager
```

### Error: Error: 802-11-wireless-security.key-mgmt: property is missing.

FIX: add ```--ask```
```Zsh
sudo nmcli device wifi connect XXXXXXXXX --ask
sudo nmcli device wifi connect XXXXXXXXX password XXXXXXXXX
```

## DNS Server

Edit `/etc/resolv.conf`

```conf
# Generated by dhcpcd from wlo1.dhcp, wlo1.dhcp6, wlo1.ra
# /etc/resolv.conf.head can replace this line
nameserver 1.1.1.1
nameserver 8.8.8.8
# nameserver 192.168.2.253
# nameserver fe80::1%wlo1
# nameserver 2402:800:20ff:109c::1
# nameserver 2402:800:20ff:5555::1
# nameserver fe80::2a77:77ff:fea8:3868%wlo1
# /etc/resolv.conf.tail can replace this line
```

## Swap L/R-Mouse

Make rule at `/etc/X11/xorg.conf.d/90-mouse-swap.conf`

```conf
Section "InputClass"
    Identifier "Swap Mouse Buttons"
    MatchIsPointer "on"
    Option "ButtonMapping" "3 2 1"
EndSection
```
## Disable PowerButton

**EDIT:** `/etc/elogind/logind.conf`
```Zsh
HandlePowerKey=ignore
```

Restart (Start if not started yet) elogind:

```Zsh
sudo ln -s  /etc/sv/elogind /var/service
```
## File browser

```Zsh
i dolphin gvfs udisks2 xdg-utils
```

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/3ce39dbf-50f2-40ec-9df9-9d96db4b8a7b" />

## Sound/Bluetooth

### Install dependancies
```Zsh
i libpulseaudio pavucontrol pulseaudio-utils pulseaudio bluez blueman bluez-alsa
```
### Enable Bluetooth

```Zsh
sudo ln -s /etc/sv/bluetoothd /var/service/bluetoothd
```
### Check pulseaudio server
```
fus@ngxxfus-lap ~
> pactl info
Server String: /run/user/1000/pulse/native
...
Server Name: pulseaudio
...
```
### Check if current user belong to `bluetooth` group

```Zsh
fus@ngxxfus-lap ~
> groups
fus bin sys kmem wheel tty tape daemon floppy disk lp dialout audio video utmp adm cdrom optical mail storage scanner network kvm input plugdev usbmon sgx users xbuilder
```

### Add current user to `bluetooth` group

```Zsh
sudo usermod -a -G bluetooth $USER
```

### Create symlink to `/var/service` to auto start `dbus` and `bluetoothd`

```Zsh
sudo ln -s /etc/sv/dbus  		/var/service/dbus
sudo ln -s /etc/sv/bluetoothd 	/var/service/bluetoothd
```

Preview: (MoveStack)

## MoveStack (patch)

SOURCE: [https://dwm.suckless.org/patches/movestack/](https://dwm.suckless.org/patches/movestack/)

**Install `patch`:**

```Zsh
i patch
```

**Downloads `dwm-movestack-20211115-a786211.diff` from `suckless`**

```Zsh
cd path/to/dwm/
curl https://dwm.suckless.org/patches/movestack/dwm-movestack-20211115-a786211.diff -o movestack.diff
patch < ./movestack.diff
```

Sumarry: That will add the function named `movestack`, help you change order of windows on tag.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/5fbf30c8-3e4d-4907-8282-ff2c1636277d" />

## Vietnamese typing with fcitx5-unikey

**DEPs:**
```Zsh
i fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-unikey
```

**ENVs:**

```Zsh
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx
export INPUT_METHOD=fcitx 		(optional)
export SDL_IM_MODULE=fcitx		(optional)
```

**IF NOT WORK WITH FIREFOX/GTKAPP (E.G: MOUSEPAD):**

```Zsh
i fcitx5-gtk4 fcitx5-gtk+2 fcitx5-gtk+3
```

**CHECK-LIST:**

```Text
CMD:		ls /usr/lib/gtk-3.0/3.0.0/immodules | grep fcitx
OUTPUT:		im-fcitx5.so
```

```Text
CMD:		echo "\$GTK_IM_MODULE = $GTK_IM_MODULE"
		echo "\$QT_IM_MODULE = $QT_IM_MODULE"
		echo "\$XMODIFIERS = $XMODIFIERS"
OUTPUT:
		$GTK_IM_MODULE = fcitx
		$QT_IM_MODULE = fcitx
		$XMODIFIERS = @im=fcitx
```

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/28bdb760-5693-443a-9937-71fd96179b0e" />

Source: [https://www.reddit.com/r/voidlinux/comments/15l6kix/fcitx5_not_working_in_certain_applications/](https://www.reddit.com/r/voidlinux/comments/15l6kix/fcitx5_not_working_in_certain_applications/)
<img width="691" height="120" alt="image" src="https://github.com/user-attachments/assets/177de707-710f-47a9-b170-1c0f92e82c2f" />


## VirtualBox

**Check if installation is available**
```Zsh
CMD:			q virtualbox
OUTPUT:			[*] virtualbox-ose-7.1.12_1            General-purpose full virtualizer for x86 hardware
			[*] virtualbox-ose-dkms-7.1.12_1       General-purpose full virtualizer for x86 hardware - kernel module sources for dkms
			[*] virtualbox-ose-guest-7.1.12_1      General-purpose full virtualizer for x86 hardware - guest utilities
			[*] virtualbox-ose-guest-dkms-7.1.12_1 General-purpose full virtualizer for x86 hardware - guest addition module source for dkms
```

**Install all**

```Zsh
i virtualbox-ose-7.1.12_1 virtualbox-ose-dkms-7.1.12_1 virtualbox-ose-guest-7.1.12_1 virtualbox-ose-guest-dkms-7.1.12_1
```
**Add `export XDG_RUNTIME_DIR=/run/user/$(id -u)` if has not added yet (in `.xinitrc`)**

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/feb1fbea-bf96-4163-a4ef-0e6974e71e73" />

## VMWare WorkStation

### Installation VMWare WorkStation
Source: [https://github.com/void-linux/void-packages/issues/33557#issuecomment-1538937175](https://github.com/void-linux/void-packages/issues/33557#issuecomment-1538937175)

<img width="1015" height="712" alt="image" src="https://github.com/user-attachments/assets/a86ea1f2-2c9d-4cf6-a633-3b252c090c2d" />

### Install module `vmmon` and `vmnet`

Source: [https://github.com/gleb-kun/vmware-host-modules/tree/workstation-17.6.1?tab=readme-ov-file](https://github.com/gleb-kun/vmware-host-modules/tree/workstation-17.6.1?tab=readme-ov-file)

```Zsh
cd vmware-host-modules
sudo make
sudo make install
```

**Error from old source:**

```
#define read_lock_list() read_lock(&dev_base_lock)
#define read_unlock_list() read_unlock(&dev_base_lock)

Change to:

#define read_lock_list() rcu_read_lock()
#define read_unlock_list() rcu_read_unlock()
```

**NOTE:** 
- Make sure `vmmon` and `vmnet` is probed via (sudo modprobe); 
- Has started `/etc/init.d/vmware start &` and `/etc/init.d/vmware-USBArbitrator start &`
- At 1st time of `vmware`, u need run it in Terminal, bcz it require Auth.

**DEMO**:
<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/ce247817-d37a-48a0-83fd-e36eba4c57e6" />

## Specify symlink for reamovable device

### Identify your device by ID

NOTE: Combine with lsblk command to determine the ID/ID_SHORT of the external drive.

```Zsh
ls -l /dev/disk/by-id/
```
<img width="1920" height="1061" alt="image" src="https://github.com/user-attachments/assets/6bbb501c-f832-4e96-bffc-f8ed7f250d08" />


### Make rule

Make rule at `/etc/udev/rules.d/99-ssd-fus.rules`

```
SUBSYSTEM=="block", ENV{ID_SERIAL_SHORT}=="012345679989", SYMLINK+="ssd_fus"
```

<img width="1920" height="1061" alt="image" src="https://github.com/user-attachments/assets/145651eb-ceaf-40dc-ad67-a48e19fc7b5c" />

# Fix unstable Mesh Wi-Fi 

My inn has a Wi-Fi Mesh System, and NetworkManager (nmcli) keeps roaming between mesh nodes (APs) with the same SSID, causing connection instability.

<img width="947" height="328" alt="image" src="https://github.com/user-attachments/assets/281e80aa-f066-4fc9-ac8e-357360c70c75" />

I will lock the the connection to a specific BSSID:
```Zsh
nmcli connection modify "BAC THIEN5g" wifi.bssid 2A:77:77:98:38:69 # BAC THIEN5g
nmcli connection down "BAC THIEN5g" && nmcli connection up "BAC THIEN5g" # Restart the connection
```

## To be cont.

# Final DEMO


<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/c1a1b827-f022-406b-b6fd-59c7cc24d405" />

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/74c2d631-afa3-471d-b4c0-bb641c421ff6" />

