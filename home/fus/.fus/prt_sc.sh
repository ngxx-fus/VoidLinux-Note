#!/bin/bash

# --- Configuration ---
# Define your screenshot directory
SCREENSHOT_DIR="$HOME/Screenshots/AutoSaved"
# Notification application name (for grouping notifications)
APP_NAME="Screenshot Tool"
# Default notification display time in milliseconds (e.g., 5000ms = 5 seconds)
DEFAULT_NOTI_TIME=5000

# --- Functions ---

# Function to send desktop notifications
# Arguments: $1=title, $2=message, $3=urgency (low, normal, critical), $4=timeout_ms (optional), $5=icon_path (optional)
send_notification() {
    local title="$1"
    local message="$2"
    local urgency="$3"
    local timeout_ms="${4:-$DEFAULT_NOTI_TIME}" # Use default if not provided
    local icon_path="$5"

    # Build the command using an array for robust argument handling
    local cmd_args=(
        "notify-send"
        "-a" "$APP_NAME"
        "-u" "$urgency"
        "-t" "$timeout_ms"
    )

    if [[ -n "$icon_path" ]]; then
        cmd_args+=("-i" "$icon_path")
    fi

    # Add title and message as the last arguments
    cmd_args+=("$title")
    cmd_args+=("$message")

    # Execute the notification command
    "${cmd_args[@]}"
}

# Function to check for necessary dependencies
check_dependencies() {
    if ! command -v notify-send &> /dev/null; then
        echo "Error: 'notify-send' not found. Please install a notification daemon (e.g., dunst) and ensure notify-send is available." >&2
        exit 1
    fi
    if ! command -v xclip &> /dev/null; then
        send_notification "Error" "xclip not found. Please install it to copy screenshots to clipboard." "critical"
        exit 1
    fi
    if ! command -v gnome-screenshot &> /dev/null; then
        send_notification "Error" "gnome-screenshot not found. Please install it." "critical"
        exit 1
    fi
}

# Function to prepare the screenshot directory
prepare_screenshot_dir() {
    mkdir -p "$SCREENSHOT_DIR" || {
        send_notification "Error" "Failed to create screenshot directory: $SCREENSHOT_DIR" "critical"
        exit 1
    }
}

# Function to generate a unique filename
generate_filename() {
    local type_prefix="$1" # e.g., "FullScreen", "Window", "Area"
    local timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
    echo "Screenshot_${type_prefix}_${timestamp}.png"
}

# Function to capture the screenshot
# Arguments: $1=capture_type (full, window, area), $2=output_path
capture_screenshot() {
    local capture_type="$1"
    local output_path="$2"
    local gnome_screenshot_options=""
    local initial_message=""

    case "$capture_type" in
        "full" )
            initial_message="Capturing full screen..."
            ;;
        "window" )
            gnome_screenshot_options="-w"
            initial_message="Click on the window to capture..."
            ;;
        "area" )
            gnome_screenshot_options="-a"
            initial_message="Drag to select the area to capture..."
            ;;
        * )
            send_notification "Invalid Usage" "Usage: $0 [full|window|area]" "critical"
            exit 1
            ;;
    esac
    
    send_notification "Screenshot" "$initial_message" "normal" 2000 # Shorter initial notification

    # Take the screenshot
    gnome-screenshot $gnome_screenshot_options -f "$output_path"
    return $? # Return the exit status of gnome-screenshot
}

# Function to copy the file to clipboard
# Arguments: $1=file_path
copy_to_clipboard() {
    local file_path="$1"
    if ! xclip -selection clipboard -t image/png -i "$file_path"; then
        send_notification "Clipboard Error" "Failed to copy screenshot to clipboard." "critical"
        return 1
    fi
    return 0
}

# --- Main Execution Logic ---
main() {
    check_dependencies
    prepare_screenshot_dir

    local capture_type="${1:-full}" # Default to 'full' if no argument
    # Capitalize first letter (e.g., "full" -> "Full")
    local filename=$(generate_filename "$(echo "$capture_type" | sed 's/\b./\u&/g')")
    local full_path="${SCREENSHOT_DIR}/${filename}"

    if capture_screenshot "$capture_type" "$full_path"; then
        if copy_to_clipboard "$full_path"; then
            send_notification "Screenshot Captured!" \
                "Saved to: ${full_path##*/}\nCopied to clipboard." \
                "normal" \
                "$DEFAULT_NOTI_TIME" \
                "$full_path" # Use the captured image as notification icon
        else
            # copy_to_clipboard already sends error notification
            : # No additional action needed here
        fi
    else
        send_notification "Screenshot Failed!" \
            "Could not capture screenshot. Ensure you interacted correctly (e.g., clicked a window or selected an area)." \
            "critical"
    fi
}

# Call the main function with all arguments passed to the script
main "$@"
