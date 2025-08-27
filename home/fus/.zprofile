printf "> source /home/fus/.fus/global_vars.sh\n"
source /home/fus/.fus/global_vars.sh

# export XDG_RUNTIME_DIR=/tmp/xdg-runtime-$UID
# mkdir -p $XDG_RUNTIME_DIR
# chmod 700 $XDG_RUNTIME_DIR

echo ""
echo "Start DWM-Xorg after 3s!"
sleep 3
exec startx
