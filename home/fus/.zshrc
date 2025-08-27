ZSH_DISABLE_COMPFIX=true
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="ngxxfus"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-bat)
source $ZSH/oh-my-zsh.sh

source /home/fus/.fus/shell_utils.sh
source /home/fus/.fus/alias

export IDF_PATH=/home/fus/.fus/esp-idf/ 
export PATH=$PATH:/home/fus/.fus/
export PATH=$PATH:/home/fus/.fus/esp-idf/
