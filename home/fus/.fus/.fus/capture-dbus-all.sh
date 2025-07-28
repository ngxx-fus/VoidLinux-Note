#!/bin/bash

dbus-monitor "interface='org.freedesktop.Notifications'" |
while read -r line; do
    if echo "$line" | grep -q "member=Notify"; then
        # Capture the next few lines of the notification message
        read -r appname_line   # string "<appname>"
        read -r replaces_id_line
        read -r icon_line
        read -r summary_line   # string "<title>"
        read -r body_line      # string "<body>"

        # Extract title and body strings
        title=$(echo "$summary_line" | sed -n 's/.*"\(.*\)".*/\1/p')
        body=$(echo "$body_line" | sed -n 's/.*"\(.*\)".*/\1/p')

        # Optional: log or debug
        echo "[+] Title: $title"
        echo "[+] Body: $body"

        # Trigger dunst via notify-send
        notify-send "$title" "$body"
    fi
done

