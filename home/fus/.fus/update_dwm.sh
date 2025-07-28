#! /bin/zsh

source /home/fus/.fus/text_effects
printf "\n\n${LYELLOW}${BOLD}[Update all]${NORM}\n"

export wm_dir=/home/fus/.WindowsManager
# export wm_dir=/tmp/tmp_wm

export dwm_dir=$wm_dir/dwm
export st_dir=$wm_dir/st
export dmenu_dir=$wm_dir/dmenu
export dwmblocks_dir=$wm_dir/dwmblocks

cd $dwm_dir
printf "\n\n${LYELLOW}${BOLD}[build] dwm@$dwm_dir${NORM}\n"
make 
printf "\n\n${LYELLOW}${BOLD}[install] dwm@$dwm_dir${NORM}\n"
sudo make  install

cd $st_dir
printf "\n\n${LYELLOW}${BOLD}[build] st@$st_dir${NORM}\n"
make 
printf "\n\n${LYELLOW}${BOLD}[install] st@$st_dir${NORM}\n"
sudo make install

cd $dmenu_dir
printf "\n\n${LYELLOW}${BOLD}[build] dmenu@$dmenu_dir${NORM}\n"
make
printf "\n\n${LYELLOW}${BOLD}[install] dmenu@$dmenu_dir${NORM}\n"
sudo make  install

cd $dwmblocks_dir
printf "\n\n${LYELLOW}${BOLD}[build] dwmblocks@$dwmblocks_dir${NORM}\n"
make clean
make
printf "\n\n${LYELLOW}${BOLD}[install] dwmblocks@$dwmblocks_dir${NORM}\n"
sudo make install

