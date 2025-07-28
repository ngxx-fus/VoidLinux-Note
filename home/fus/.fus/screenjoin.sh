#!/bin/sh

# Define display names
INTERNAL="eDP1"
EXTERNAL="HDMI1"

# Align external monitor ABOVE internal one
xrandr \
  --output "$INTERNAL" --auto --pos 0x1080 \
  --output "$EXTERNAL" --auto --pos 256x0
