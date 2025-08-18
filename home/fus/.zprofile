printf "> source /home/fus/.fus/global_vars.sh\n"
source /home/fus/.fus/global_vars.sh

echo ""
echo "Start DWM-Xorg after 3s!"
sleep 3
exec startx
