#!/bin/zsh

# PART 1 - FUNCTIONS #######################################################

export DATE_PATH=/usr/bin/date
print_msg(){
    echo -e "[$( ${DATE_PATH} +'%y/%m/%d %H:%M:%S.%3N' )] $*"
}

yes_or_no(){
	while true; 
	do
		printf "Y/N? "
		read yn
		case $yn in
            [Yy]* )   return 0;;
			[Nn]* )   return 1;;
        	esac
    	done
}

# PART 2 - TEXT EFFECTS #####################################################
export BOLD="\e[1m"
export FAINT="\e[2m"
export ITALIC="\e[3m"
export UNDERLINED="\e[4m"
export BLACK="\e[30m"
export RED="\e[31m"
export GREEN="\e[32m"
export YELLOW="\e[33m"
export BLUE="\e[34m"
export MEGENTA="\e[35m"
export CYAN="\e[36m"
export LGRAY="\e[37m"
export GRAY="\e[90m"
export LRED="\e[91m"
export LGREEN="\e[92m"
export LYELLOW="\e[93m"
export LBLUE="\e[94m"
export LMEGENTA="\e[95m"
export LCYAN="\e[96m"
export WHITE="\e[m97"
export BG_BLACK="\e[40m"
export BG_RED="\e[41m"
export BG_GREEN="\e[42m"
export BG_YELLOW="\e[43m"
export BG_BLUE="\e[44m"
export BG_MEGENTA="\e[45m"
export CYAN="\e[46m"
export BG_LGRAY="\e[47m"
export BG_GRAY="\e[100m"
export BG_LRED="\e[101m"
export BG_LGREEN="\e[102m"
export BG_LYELLOW="\e[103m"
export BG_LBLUE="\e[104m"
export BG_LMEGENTA="\e[105m"
export BG_LCYAN="\e[106m"
export BG_WHITE="\e[m107"
export NORMAL="\e[0m"
export NORM="\e[0m"
export ENDCOLOR="\e[0m"
