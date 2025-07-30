#!/bin/zsh

# === Configurable Variables ===
screenshots_dir="$HOME/Pictures/Screenshots"
maim_bin="/usr/bin/maim"
tee_bin="/usr/bin/tee"
xclip_bin="/usr/bin/xclip"
notify_bin="/usr/bin/notify-send"
default_noti_time=5000
app_name="Screenshot Tool"
# === Functions ===

notify() {
    local title="$1" msg="$2" urgency="${3:-normal}" timeout="${4:-$default_noti_time}" icon="${5:-}"
    $notify_bin -a "$app_name" -u "$urgency" -t "$timeout" ${icon:+-i "$icon"} "$title" "$msg"
}

check_bins() {
    for bin in "$maim_bin" "$tee_bin" "$xclip_bin" "$notify_bin"; do
        command -v "$bin" >/dev/null || {
            echo "Missing required binary: $bin" >&2
            notify "Missing Binary" "$bin not found in PATH" critical
            exit 1
        }
    done
}

gen_filename() {
    date +"screenshot-%F_%H-%M-%S.png"
}

take_shot() {
    local mode="$1" filename="$screenshots_dir/$(gen_filename)"
    local msg icon_opt

    case "$mode" in
        --full)   msg="Full screen"; cmd="$maim_bin";;
        --window) msg="Active window"; cmd="$maim_bin -i $(xdotool getactivewindow)";;
        --area)   msg="Select area"; cmd="$maim_bin -s";;
        *) notify "Usage Error" "Use --full, --area, or --window" critical; exit 1;;
    esac

    notify "Screenshot" "Taking $msg..." low 1000
    eval "$cmd" | "$tee_bin" "$filename" | "$xclip_bin" -selection clipboard -t image/png

    if [ $? -eq 0 ]; then
        notify "Captured" "Saved ${filename##*/},\nCopied to clipboard!" normal "$default_noti_time"
    else
        notify "Error" "Screenshot failed." critical
        exit 1
    fi
}

# === Main ===
if [ $# -eq 0 ]; then
    notify "Usage" "Use: $0 --full | --area | --window" critical
    exit 1
fi

check_bins
mkdir -p "$screenshots_dir"
take_shot "$1"

