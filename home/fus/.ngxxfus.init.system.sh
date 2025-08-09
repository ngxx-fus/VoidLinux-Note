#!/bin/sh 

########### COLORS ###########################################
export BOLD="\033[1m"
export FAINT="\033[2m"
export ITALIC="\033[3m"
export UNDERLINED="\033[4m"
export BLACK="\033[30m"
export RED="\033[31m"
export GREEN="\033[32m"
export YELLOW="\033[33m"
export BLUE="\033[34m"
export MAGENTA="\033[35m"
export CYAN="\033[36m"
export LGRAY="\033[37m"
export GRAY="\033[90m"
export LRED="\033[91m"
export LGREEN="\033[92m"
export LYELLOW="\033[93m"
export LBLUE="\033[94m"
export LMAGENTA="\033[95m"
export LCYAN="\033[96m"
export WHITE="\033[97m"
export BG_BLACK="\033[40m"
export BG_RED="\033[41m"
export BG_GREEN="\033[42m"
export BG_YELLOW="\033[43m"
export BG_BLUE="\033[44m"
export BG_MAGENTA="\033[45m"
export BG_CYAN="\033[46m"
export BG_LGRAY="\033[47m"
export BG_GRAY="\033[100m"
export BG_LRED="\033[101m"
export BG_LGREEN="\033[102m"
export BG_LYELLOW="\033[103m"
export BG_LBLUE="\033[104m"
export BG_LMAGENTA="\033[105m"
export BG_LCYAN="\033[106m"
export BG_WHITE="\033[107m"
export NORM="\033[0m"

#############################################################

install="sudo xbps-install -Sy"
update="sudo xbps-install -Suy"

echo "${BOLD}${LYELLOW}# ============================================================================= #${NORM}"
echo "${BOLD}${LYELLOW}#                            HELLO FROM NGXXFUS                                 #${NORM}" 
echo "${BOLD}${LYELLOW}# ============================================================================= #${NORM}"

echo "${WHITE}
Hi there,

    I'm ${UNDERLINED}ngxxfus${NORM}${WHITE}. My name is ${BOLD}Phu${NORM}${WHITE} — it’s pronounced like foo. I made this script 
to initialize my system (a 5-year-old laptop). It will install some necessary 
packages that I have collected from various tests before. Thank you for using 
my script!

Contacts:
    - github.com/ngxx-fus
    - msnp@outlook.com 
    - instagram.com/ngxx.fus
${NORM}"

if [ "$(whoami)" = "root" ]; then
    echo "${LRED}You are running the script as ${BOLD}root${NORM}${LRED} user, some file/dir is write on normal user at ~ 
(/homne/your_username), but with root user ~ is /root!${NORM}"
    echo "${LRED}Please run as normal user!!!!${NORM}"
    exit 1
fi
do_you_want_to_continue(){
    echo "Do you want to ${BOLD}${UNDERLINED}continue${NORM}? Y/N";
    while true; do 
        printf "${GRAY}Your answer:${NORM} "
        read ans 
        echo "${GRAY}Got the answer:${NORM} \"$ans\""
        case $ans in
            [Yy]*)
                echo "${LGREEN}Oke, i will continue, you need enter your password for ${BOLD}$(whoami)${NORM}!"
                return 0
                ;;
            [Nn]*)
                echo "${LRED}${BOLD}I got it, cancel!${NORM}"
                return 1
                ;;
            *)
                echo "Please enter ${UNDERLINED}${BOLD}correct${NORM} form !"
        esac
    done
}


do_you_want_to_continue
if [ $? -eq 1 ]; then exit 1; fi 

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Update ${BOLD}${UNDERLINED}xbps${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

$install xbps

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Update system${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

$update

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Make some necessary dirs${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}tree:${NORM}
~
├── .config
├── Desktop
├── Documents
├── Downloads
├── Pictures
└── Videos
"

cd ~
mkdir .config
mkdir Desktop
mkdir Documents
mkdir Downloads
mkdir Pictures
mkdir Videos

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Install utils${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}btop: modern resource monitor with mouse support and beautiful TUI (like htop but better)${NORM}"
$install btop

echo "${LYELLOW}upower: provides battery and power statistics for laptops; used by status bars like dwmblocks${NORM}"
$install upower

echo "${LYELLOW}dbus: essential message bus system for communication between desktop apps and services${NORM}"
$install dbus

echo "${LYELLOW}elogind: manages user sessions and permissions (needed for shutdown, suspend, logout in DWM)${NORM}"
$install elogind

echo "${LYELLOW}udisks2: allows safe mounting/unmounting of USB drives and disks; needed by GUI file managers${NORM}"
$install udisks2

echo "${LYELLOW}acpid: listens to ACPI events (lid close, power button); used for laptop power handling${NORM}"
$install acpid

echo "${LYELLOW}xclip: access X11 clipboard from terminal (used in screenshot scripts, copy-paste from CLI)${NORM}"
$install xclip

echo "${LYELLOW}xdotool: simulate keyboard and mouse input, window movement, and other X11 actions${NORM}"
$install xdotool

echo "${LYELLOW}maim: fast screenshot tool (like \`scrot\`, supports selection and automation with \`xdotool\`)${NORM}"
echo "${LYELLOW}scrot: simple screenshot tool (less modern but widely supported and scriptable)${NORM}"
$install maim scrot

echo "${LYELLOW}NetworkManager: universal network configuration daemon; works with \`nmtui\`, \`nmcli\`, and GUIs${NORM}"
$install NetworkManager

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}UI & appearance tools${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}dunst: lightweight and configurable notification daemon (used by \`notify-send\`)${NORM}"
$install dunst

echo "${LYELLOW}feh: fast image viewer and wallpaper setter (used to set backgrounds in \`.xinitrc\`)${NORM}"
$install feh

echo "${LYELLOW}picom: compositor for X11 to enable transparency, shadows, fading, and VSync (essential for eye-candy)${NORM}"
$install picom

echo "${LYELLOW}fastfetch: minimal and blazing-fast system info fetcher (alternative to neofetch)${NORM}"
$install fastfetch

echo "${LYELLOW}xdg-utils: desktop integration tools like \`xdg-open\` (used to open files/URLs with default apps)${NORM}"
$install xdg-utils

echo "${LYELLOW}ro-fi: luncher${NORM}"
$install rofi

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Development tools${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}gcc, make, autoconf: core tools for compiling C/C++ programs and building most open-source projects${NORM}"
$install gcc make autoconf

echo "${LYELLOW}ripgrep (rg): blazing-fast search tool (like grep, but recursive, respects .gitignore, and faster)${NORM}"
$install ripgrep

echo "${LYELLOW}git: distributed version control system; essential for downloading source code (like suckless)${NORM}"
$install git

echo "${LYELLOW}gh-cli: GitHub CLI to interact with GitHub repositories, issues, pull requests directly from terminal${NORM}"
$install gh-cli

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}Internet tools${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}curl: flexible tool to make HTTP requests, download files, or interact with APIs (used everywhere)${NORM}"
$install curl

echo "${LYELLOW}firefox: full-featured web browser; replace with chromium or other if preferred${NORM}"
$install firefox

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW}terminal emulator${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}alacritty: GPU-accelerated terminal emulator (fast, minimal, with modern rendering)${NORM}"
$install alacritty

echo "${LYELLOW}Nerd fornts (It'll take 1.5G free space on your disk)${NORM}"
do_you_want_to_continue
if [ $? -eq 0 ]; then
    $install liberation-fonts-ttf nerd-fonts-ttf
fi

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} Zsh shell/Oh-my-zsh${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}zsh${NORM}"
$install zsh 

echo "${LYELLOW}Change root/${whoami}'s shell to ZSH${NORM}"

do_you_want_to_continue
if [ $? -eq 0 ]; then 
    if [ -e /bin/zsh ]; then
        sudo chsh root -s /bin/zsh
        sudo chsh $(whoami) -s /bin/zsh
    else
        echo "${LRED}ZSH not found at /bin/zsh${NORM}"
    fi
fi

echo "${LYELLOW}Oh-my-zsh${NORM}"
if [ -e /bin/zsh ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "${LRED}ZSH not found at /bin/zsh${NORM}"
fi
 
echo "${LYELLOW}Restore ngxxfus's custom them at <~/.oh-my-zsh/themes/ngxxfus.zsh-theme>${NORM}"
echo "
PROMPT=\'%{$fg_bold[white]%}%n@%m%{$reset_color%} %(?:%{$fg_bold[green]%}%c:%{$fg_bold[red]%}%c) %{$reset_color%}$(git_prompt_info)
%{$fg_bold[cyan]%}> %{$reset_color%}\'

ZSH_THEME_GIT_PROMPT_PREFIX=\"%{$fg_bold[blue]%}git:(%{$fg[red]%}\"
ZSH_THEME_GIT_PROMPT_SUFFIX=\"%{$reset_color%} \"
ZSH_THEME_GIT_PROMPT_DIRTY=\"%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}\"
ZSH_THEME_GIT_PROMPT_CLEAN=\"%{$fg[blue]%})\"
" | tee ~/.oh-my-zsh/themes/ngxxfus.zsh-theme

echo "${LYELLOW}Restore .zshrc${NORM}"
echo "
ZSH_DISABLE_COMPFIX=true
export ZSH=\"$HOME/.oh-my-zsh\"
ZSH_THEME=\"ngxxfus\"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-bat)
source $ZSH/oh-my-zsh.sh
" | tee ~/.zshrc

echo "${LYELLOW}Install Oh-my-zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting, zsh-bat)${NORM}"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/fdellwing/zsh-bat.git $ZSH_CUSTOM/plugins/zsh-bat

echo "${LYELLOW}Make symlink for root user${NORM}"
current_user=$(whoami)
sudo ln -s /home/$current_user/.oh-my-zsh /root/.oh-my-zsh

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} Neovim${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

if [ -e /bin/nvim ]; then
    echo "${LYELLOW}Not found /bin/nvim! --> Install nvim${NORM}"
    $install neovim 
fi 

echo "${LYELLOW}Clone ngxxfus's config on git${NORM}"
mkdir -p /home/fus/$current_user/.config/
git clone https://github.com/ngxx-fus/neovim-conf.git /home/fus/$current_user/.config/nvim

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} Set-up desktop environment${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}Install ralated packages${NORM}"
$install xorg xinit xrandr xf86-video-intel git make gcc pkg-config libX11-devel libXft-devel libXinerama-devel

echo "${LYELLOW}Clone DWM, DWMBLOCKS, DMENU into ~/.display${NORM}"
mkdir -p ~/.display 
if [ -e  ~/.display ]; then 
    echo "${LYELLOW} ~/.display/ existed!!!$NORM"
else
    git clone https://github.com/Digital-Chaos/dwm.git              ~/.display/dwm 
    git clone https://github.com/torrinfail/dwmblocks.git           ~/.display/dwmblocks 
    git clone https://github.com/Digital-Chaos/dmenu.git            ~/.display/dmenu 
    echo "${LYELLOW}Compile and install DWM, DWMBLOCKS. DMENU${NORM}"
    apps=(dwm dwmblocks dmenu)
    for app in $apps; do 
        echo "${BOLD}Install $app${NORM}"
        cd ~/.display/$app 
        sudo make install
        make
    done
    cd ~
fi

if [ -e ~/.xinitrc ]; then
    echo "${YELLOW}~/.xinitrc existed!!!$NORM"
else
    echo "${LYELLOW}Write .xinitrc${NORM}"
    echo "
    # GLOBAL VARS #################################################################
    export _HDMI=$(xrandr | grep -E \'^HDMI\[-0-9\]* connected\' | awk \'\{print $1\}\')
    export _eDP=$(xrandr | grep -E \'^eDP\[-0-9\]* connected\' | awk \'\{print $1\}\')
    export BROWSER=firefox
    export XDG_RUNTIME_DIR=/run/user/\$\(id -u\)
    export ROFI_PNG_OUTPUT=/home/fus/Pictures/Rofi-Captures.jpg
    export GTK_IM_MODULE=fcitx
    export QT_IM_MODULE=fcitx
    export XMODIFIERS=@im=fcitx 
    # START-UP APP ################################################################
    exec /usr/local/bin/dwmblocks                           					&
    exec /usr/bin/fcitx5                                                        &
    # DWM ######################################################################### 
    exec dwm
    " | tee ~/.xinitrc
fi

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} Install NetworkManager${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}Install nmcli${NORM}"

$install NetworkManager

echo "${LYELLOW}Add to runit startup${NORM}"
sudo ln -s /etc/sv/NetworkManager /var/service 

echo "${LYELLOW}Edit resolv${NORM}"
sudo mv /etc/resolv.conf /etc/resolv.conf.orig
sudo echo "
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 9.9.9.9
# nameserver 192.168.1.1
# nameserver 192.168.2.253
# nameserver 1.0.0.1
" | sudo tee /etc/resolv.conf

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} Swap LEFT/RIGHT-mouse (via rule udev)${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

do_you_want_to_continue
if [ $? -eq 0 ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d/
    echo "Section \"InputClass\"
    Identifier \"Swap Mouse Buttons\"
    MatchIsPointer \"on\"
    Option \"ButtonMapping\" \"3 2 1\"
EndSection
" | sudo tee /etc/X11/xorg.conf.d/90-mouse-swap.conf
fi

echo "${LYELLOW}=============================================================================${NORM}"
echo "${LYELLOW} UNIKEY (Vietnamese)${NORM}"
echo "${LYELLOW}=============================================================================${NORM}"

echo "${LYELLOW}Install fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-unikey fcitx5-gtk4 fcitx5-gtk+2 fcitx5-gtk+3${NORM}"
$install fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-unikey fcitx5-gtk4 fcitx5-gtk+2 fcitx5-gtk+3

echo "
#\!/bin/bash

# Search for the built-in keyboard by name
BUILT_IN_KB=\$(xinput list | grep -i \"AT Translated Set 2 keyboard\" | grep -o \'id=[0-9]*\' | cut -d= -f2)

# Check if ID was found
if [[ -n \"$BUILT_IN_KB\" ]]; then
    echo \"Built-in keyboard ID: $BUILT_IN_KB\"
    xinput disable \"$BUILT_IN_KB\"
    echo \"Built-in keyboard disabled.\"
else
    echo \"Built-in keyboard not found.\"
    exit 1
fi
" | tee ~/.fus/disable_built_in_keyboard.sh
