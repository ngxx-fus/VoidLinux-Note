#  #!/bin/zsh
#  
#  export PACTL="/usr/bin/pactl"
#  
#  # Get default sink for user 'fus'
#  export DEF_SINK=$(sudo -u fus \
#    XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
#    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
#    "$PACTL" get-default-sink)
#  
#  # Get current volume (first channel)
#  export SVOLUME_VALUE=$(sudo -u fus \
#    XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
#    DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
#    "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')
#  
#  # Set volume to a specific value
#  set_volume() {
#      sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
#                  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
#                  "$PACTL" set-sink-volume "$DEF_SINK" $1
#  }
#  
#  # Volume up (max 100%)
#  volume_up() {
#      if [ $SVOLUME_VALUE -lt 100 ]; then
#          SVOLUME_VALUE=$((SVOLUME_VALUE + 1))
#          set_volume "${SVOLUME_VALUE}%"
#      fi
#  }
#  
#  # Volume down (min 0%)
#  volume_down() {
#      if [ $SVOLUME_VALUE -gt 0 ]; then
#          SVOLUME_VALUE=$((SVOLUME_VALUE - 1))
#          set_volume "${SVOLUME_VALUE}%"
#      fi
#  }
#  
#  # Toggle mute
#  volume_mute_toggle() {
#      sudo -u fus XDG_RUNTIME_DIR="/run/user/$(id -u fus)" \
#                  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u fus)/bus" \
#                  "$PACTL" set-sink-mute "$DEF_SINK" toggle
#  }
#  
#  # ======= Argument Parsing =======
#  
#  case "$1" in
#      --up)
#          volume_up
#          ;;
#      --down)
#          volume_down
#          ;;
#      --toggle)
#          volume_mute_toggle
#          ;;
#      --get-volume)
#          echo "$SVOLUME_VALUE"
#          ;;
#      *)
#          echo "Usage: $0 [--up | --down | --toggle | --get-volume ]"
#          exit 1
#          ;;
#  esac
#

#!/bin/zsh

export PACTL="/usr/bin/pactl"
export USERNAME="fus"
export UID=$(id -u $USERNAME)
export XDG_RUNTIME_DIR="/run/user/$UID"
export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"

# Get default sink for user 'fus'
export DEF_SINK=$(sudo -u $USERNAME \
  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
  "$PACTL" get-default-sink)

# Get current volume (first channel)
export SVOLUME_VALUE=$(sudo -u $USERNAME \
  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
  "$PACTL" get-sink-volume "$DEF_SINK" | awk -F'/' '/Volume:/ {gsub(/ /, "", $2); print $2}' | tr -d '%')

# Get current mute state (yes/no)
export IS_MUTED=$(sudo -u $USERNAME \
  XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
  DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
  "$PACTL" get-sink-mute "$DEF_SINK" | awk '{print $2}')

# Set volume
set_volume() {
    sudo -u $USERNAME XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
                      DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                      "$PACTL" set-sink-volume "$DEF_SINK" $1
}

# Set mute state
set_mute() {
    sudo -u $USERNAME XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR \
                      DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS \
                      "$PACTL" set-sink-mute "$DEF_SINK" $1
}

# Volume up
volume_up() {
    if [ $SVOLUME_VALUE -lt 100 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE + 1))
        set_volume "${SVOLUME_VALUE}%"
        if [ "$IS_TOGGLE" -eq 0 ] && [ "$IS_MUTED" = "yes" ]; then
            set_mute 0
        fi
    fi
}

# Volume down
volume_down() {
    if [ $SVOLUME_VALUE -gt 0 ]; then
        SVOLUME_VALUE=$((SVOLUME_VALUE - 1))
        set_volume "${SVOLUME_VALUE}%"
        if [ "$IS_TOGGLE" -eq 0 ] && [ "$SVOLUME_VALUE" -eq 0 ]; then
            set_mute 1
        fi
    fi
}

# Toggle mute
volume_mute_toggle() {
    set_mute toggle
}

# Default: toggle behavior disabled (1 = don't auto-toggle mute)
IS_TOGGLE=1

# Parse optional --is-toggle flag (second argument)
if [ "$2" = "--is-toggle" ] && [[ "$3" =~ ^[01]$ ]]; then
    IS_TOGGLE=$3
fi

# ======= Argument Parsing =======
case "$1" in
    --up)
        volume_up
        ;;
    --down)
        volume_down
        ;;
    --toggle)
        volume_mute_toggle
        ;;
    --get-volume)
        echo "$SVOLUME_VALUE"
        ;;
    *)
        echo "Usage: $0 [--up|--down|--toggle|--get-volume] [--is-toggle 0|1]"
        exit 1
        ;;
esac

