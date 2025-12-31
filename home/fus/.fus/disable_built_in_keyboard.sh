#!/bin/zsh

# Search for the built-in keyboard by name
BUILT_IN_KB=$(xinput list | grep -i "AT Translated Set 2 keyboard" | grep -o 'id=[0-9]*' | cut -d= -f2)

# Check if ID was found
if [[ -n "$BUILT_IN_KB" ]]; then
    echo "Built-in keyboard ID: $BUILT_IN_KB"
    xinput disable "$BUILT_IN_KB"
    echo "Built-in keyboard disabled."
else
    echo "Built-in keyboard not found."
    exit 1
fi

