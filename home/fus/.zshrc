# @file .zshrc
# @brief Interactive shell configuration.

ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ngxxfus"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-bat)

source $ZSH/oh-my-zsh.sh

# --- CUSTOM INCLUDES ---

# 1. Source Utils (AGAIN)
# @note We source this here to get the FUNCTIONS (print_msg, yes_or_no)
# because functions are NOT inherited from parent processes.
if [ -f "$HOME/.fus/shell_utils.sh" ]; then
    source "$HOME/.fus/shell_utils.sh"
fi

# 2. Source Aliases
if [ -f "$HOME/.fus/alias" ]; then
    source "$HOME/.fus/alias"
fi

