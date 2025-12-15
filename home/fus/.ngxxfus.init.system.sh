#!/bin/bash

########### COLORS #########################################################
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
export NORM="\033[0m"

# VAR ######################################################################

# Fix: Added -y to auto confirm installation
install="sudo xbps-install -Suy" 
update="sudo xbps-install -Suy"

# HELPERS ##################################################################

printTitle() {
    local term_width=80
    local text="$*"
    local text_len=${#text}
    local inner_width=$((term_width - 4))
    if [ $text_len -gt $inner_width ]; then
        text="${text:0:$inner_width}"
        text_len=$inner_width
    fi
    local left=$(( (inner_width - text_len) / 2 ))
    local right=$(( inner_width - text_len - left ))
    echo -e "${BOLD}${LYELLOW}# ############################################################################ #${NORM}"
    printf "${BOLD}${LYELLOW}# %${left}s%s%${right}s #${NORM}\n" "" "$text" ""
    echo -e "${BOLD}${LYELLOW}# ############################################################################ #${NORM}"
}

installPkg() {
    # Fix: Quotes "$@" to handle arguments with spaces properly
    printf "\n${BOLD}${LGREEN}INSTALL [$*]${NORM}\n";
    $install "$@"
}

############################################################################

printTitle "Hello from NgxxFus!"

echo -e "${WHITE}
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

# Check root logic is correct
if [ "$(whoami)" = "root" ]; then
    echo -e "${LRED}You are running the script as ${BOLD}root${NORM}${LRED} user. Home directory issues may occur.${NORM}"
    echo -e "${LRED}Please run as normal user!!!!${NORM}"
    exit 1
fi

do_you_want_to_continue(){
    echo -e "Do you want to ${BOLD}${UNDERLINED}continue${NORM}? Y/N";
    while true; do 
        printf "${GRAY}Your answer:${NORM} "
        read -r ans 
        echo -e "${GRAY}Got the answer:${NORM} \"$ans\""
        case $ans in
            [Yy]*)
                echo -e "${LGREEN}Okay, I will continue. You need to enter password for ${BOLD}$(whoami)${NORM}!"
                return 0
                ;;
            [Nn]*)
                echo -e "${LRED}${BOLD}I got it, cancel!${NORM}"
                return 1
                ;;
            *)
                echo "Please enter ${UNDERLINED}${BOLD}correct${NORM} form (Y/N)!"
        esac
    done
}


do_you_want_to_continue
if [ $? -eq 1 ]; then exit 1; fi 

printTitle "Update xbps"
# Note: xbps usually needs to update itself first explicitly before packages
sudo xbps-install -u xbps

printTitle "Update system"
$update

printTitle "Make some necessary dirs"

echo -e "${LYELLOW}tree:${NORM}
    ~
    ├── .config
    ├── Desktop
    ├── Documents
    ├── Downloads
    ├── Pictures
    └── Videos
"

cd ~ || exit
# Fix: Added -p to avoid errors if directory exists
mkdir -p .config Desktop Documents Downloads Pictures Videos

printTitle "Install utils"

# List combined to reduce sudo calls (optional but faster)
installPkg btop upower dbus elogind udisks2 acpid xclip xdotool maim scrot \
           NetworkManager dunst feh picom fastfetch xdg-utils rofi \
           gcc make autoconf ripgrep git gh-cli curl firefox chromium \
           alacritty zsh tree \
           Imlib2-devel SDL2_image-devel SDL2_mixer-devel SDL2_ttf-devel \
           base-devel clang-tools-extra dconf-editor libX11-devel \
           libXau-devel libXdmcp-devel libXext-devel libXft-devel \
           libXinerama-devel libXrandr-devel libinput pam-devel \
           xf86-input-libinput dhclient lm_sensors

echo -e "${LYELLOW}Nerd fonts (It'll take 1.5G free space on your disk)${NORM}"
do_you_want_to_continue
if [ $? -eq 0 ]; then
    installPkg liberation-fonts-ttf nerd-fonts-ttf
fi

printTitle "Zsh shell/Oh-my-zsh"

echo -e "${LYELLOW}Change root/$(whoami)'s shell to ZSH${NORM}"

do_you_want_to_continue
if [ $? -eq 0 ]; then 
    if [ -e /bin/zsh ]; then
        sudo chsh root -s /bin/zsh
        sudo chsh "$(whoami)" -s /bin/zsh
    else
        echo -e "${LRED}ZSH not found at /bin/zsh${NORM}"
    fi
fi

echo -e "${LYELLOW}Oh-my-zsh${NORM}"
if [ -e /bin/zsh ]; then
    # Fix: Added UNATTENDED=true to prevent zsh from entering the shell and stopping the script
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
         echo "Oh-my-zsh already installed."
    fi
else
    echo -e "${LRED}ZSH not found at /bin/zsh${NORM}"
fi
 
echo -e "${LYELLOW}Restore ngxxfus's custom theme at <~/.oh-my-zsh/themes/ngxxfus.zsh-theme>${NORM}"

# Fix: Use HEREDOC with 'EOF' to prevent variable expansion ($) during script execution
cat << 'EOF' > ~/.oh-my-zsh/themes/ngxxfus.zsh-theme
PROMPT='%{$fg_bold[white]%}%n@%m%{$reset_color%} %(?:%{$fg_bold[green]%}%c:%{$fg_bold[red]%}%c) %{$reset_color%}$(git_prompt_info)
%{$fg_bold[cyan]%}> %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}%1{✗%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"
EOF

echo -e "${LYELLOW}Restore .zshrc${NORM}"
cat << 'EOF' > ~/.zshrc
ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ngxxfus"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-bat)
source $ZSH/oh-my-zsh.sh
EOF

echo -e "${LYELLOW}Install Oh-my-zsh plugins${NORM}"
# Fix: Clone directly to avoid expansion confusion and handle existing dirs
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>/dev/null
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>/dev/null
git clone https://github.com/fdellwing/zsh-bat.git "$ZSH_CUSTOM/plugins/zsh-bat" 2>/dev/null

echo -e "${LYELLOW}Make symlink for root user${NORM}"
current_user=$(whoami)
# Fix: Check if link exists before creating
if [ ! -e /root/.oh-my-zsh ]; then
    sudo ln -s "/home/$current_user/.oh-my-zsh" /root/.oh-my-zsh
fi

printTitle "Install fav editor - neovim"

# Fix: Logic reversed. Should be if [ ! -e ... ] (if NOT exists)
if [ ! -e /usr/bin/nvim ] && [ ! -e /bin/nvim ]; then
    echo -e "${LYELLOW}Not found /bin/nvim! --> Install nvim${NORM}"
    installPkg neovim 
fi 

echo -e "${LYELLOW}Clone ngxxfus's config on git${NORM}"
# Fix: Path fixed to $HOME/.config
mkdir -p "$HOME/.config"
if [ ! -d "$HOME/.config/nvim" ]; then
    git clone https://github.com/ngxx-fus/neovim-conf.git "$HOME/.config/nvim"
fi

printTitle "Set-up desktop environment"

echo -e "${LYELLOW}Install related packages${NORM}"
installPkg xorg pkg-config xinit xrandr xf86-video-intel \
           make gcc git base-devel pam-devel \
           libX11-devel libXft-devel libXinerama-devel libXext-devel \
           libXrandr-devel libXdmcp-devel libXau-devel \
           SDL2_image-devel SDL2_mixer-devel SDL2_ttf-devel

echo -e "${LYELLOW}Clone DWM, DWMBLOCKS, DMENU into ~/.display${NORM}"

if [ -d ~/.display ]; then 
    echo -e "${LYELLOW} ~/.display/ existed!!!${NORM}"
else
    mkdir -p ~/.display/dwm 
    mkdir -p ~/.display/dmenu 
    mkdir -p ~/.display/dwmblocks
    
    git clone https://github.com/Digital-Chaos/dwm.git          ~/.display/dwm 
    git clone https://github.com/torrinfail/dwmblocks.git       ~/.display/dwmblocks 
    git clone https://github.com/Digital-Chaos/dmenu.git        ~/.display/dmenu 
    
    echo -e "${LYELLOW}Compile and install DWM, DWMBLOCKS, DMENU${NORM}"
    # Bash array syntax needs #!/bin/bash
    apps=(dwm dwmblocks dmenu)
    for app in "${apps[@]}"; do 
        echo -e "${BOLD}Install $app${NORM}"
        cd "$HOME/.display/$app" || continue
        # Fix: make clean first, then compile, then install
        make clean
        make
        sudo make install
    done
    cd ~ || exit
fi

if [ -e ~/.xinitrc ]; then
    echo -e "${YELLOW}~/.xinitrc existed!!!${NORM}"
else
    echo -e "${LYELLOW}Write .xinitrc${NORM}"
    # Fix: Escaping for xinitrc content
    cat << 'EOF' > ~/.xinitrc
# GLOBAL VARS #################################################################
export _HDMI=$(xrandr | grep -E '^HDMI[-0-9]* connected' | awk '{print $1}')
export _eDP=$(xrandr | grep -E '^eDP[-0-9]* connected' | awk '{print $1}')
export BROWSER=firefox
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export ROFI_PNG_OUTPUT=$HOME/Pictures/Rofi-Captures.jpg
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx 
# START-UP APP ################################################################
exec /usr/local/bin/dwmblocks &
exec /usr/bin/fcitx5 &
# DWM ######################################################################### 
exec dwm
EOF
fi

printTitle "Install NetworkManager"

echo -e "${LYELLOW}Install nmcli${NORM}"
installPkg NetworkManager

echo -e "${LYELLOW}Add to runit startup${NORM}"
# Fix: Check if service link already exists
if [ ! -L /var/service/NetworkManager ]; then
    sudo ln -s /etc/sv/NetworkManager /var/service 
fi

echo -e "${LYELLOW}Edit resolv${NORM}"
if [ -f /etc/resolv.conf ]; then
    sudo mv /etc/resolv.conf /etc/resolv.conf.orig
fi
echo "nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 9.9.9.9" | sudo tee /etc/resolv.conf > /dev/null

printTitle "Swap LEFT/RIGHT-mouse (via rule udev)"

do_you_want_to_continue
if [ $? -eq 0 ]; then
    sudo mkdir -p /etc/X11/xorg.conf.d/
    echo 'Section "InputClass"
    Identifier "Swap Mouse Buttons"
    MatchIsPointer "on"
    Option "ButtonMapping" "3 2 1"
EndSection' | sudo tee /etc/X11/xorg.conf.d/90-mouse-swap.conf > /dev/null
fi

printTitle "UNIKEY (Vietnamese)"

installPkg fcitx5 fcitx5-qt fcitx5-gtk fcitx5-configtool fcitx5-unikey fcitx5-gtk4 
# fcitx5-gtk+2 fcitx5-gtk+3 might be named differently depending on repo, check void packages

mkdir -p ~/.fus
cat << 'EOF' > ~/.fus/disable_built_in_keyboard.sh
#!/bin/bash
# Search for the built-in keyboard by name
BUILT_IN_KB=$(xinput list | grep -i "AT Translated Set 2 keyboard" | grep -o 'id=[0-9]*' | cut -d= -f2)

# Check if ID was found
if [[ -n "$BUILT_IN_KB" ]]; then
    echo "Built-in keyboard ID: $BUILT_IN_KB"
    xinput disable "$BUILT_IN_KB"
    echo "Built-in keyboard disabled."
else
    echo "Built-in keyboard not found."
    exit 1
fi
EOF
chmod +x ~/.fus/disable_built_in_keyboard.sh

printTitle "Install RESTORE FROM LOCAL"

printf "\n${LGREEN}Enter path (from root /) to VoidLinux-Note dir${NORM}\n"

export VoidLinux_Note_Dir='/home/fus/Downloads/VoidLinux-Note'

echo -e "${BOLD}${LGREEN}Installation Finished! Please reboot.${NORM}"
