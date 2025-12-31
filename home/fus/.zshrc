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
if [ -f "$HOME/.fus/user_aliases.sh" ]; then
    source "$HOME/.fus/user_aliases.sh"
fi

if [ -f "$HOME/.fus/esp-idf/export.sh" ]; then 
    alias get_idf="source /home/fus/.fus/esp-idf/export.sh"
    alias idf_init="source /home/fus/.fus/esp-idf/export.sh"
fi

if [[ -n "$TMUX" ]]; then
  export TERM=tmux-256color
else
  export TERM=xterm-256color
fi

export GEMINI_API_KEY="AIzaSyDzzUlolOmuKT0AZKT3oQLnj7xnh0blbRA"
