#!/bin/sh

# Define display names
INTERNAL="eDP1"
EXTERNAL="HDMI1"

# =========================================================
# CONFIGURATION 1: Side-by-Side (Current Active)
# =========================================================

# @brief Configures dual display layout (External Right of Internal).
#
# Sets the External monitor to the right of the Internal monitor,
# aligned slightly higher (negative vertical offset relative to Internal).
#
# **Screen Layout Illustration:**
#
#      y=0            (1366,0)
#       -----------------+------------------------+
#                        |                        |
#       y=320            |    EXTERNAL (HDMI1)    |
#     +------------------+                        |
#     |                  |                        |
#     |     INTERNAL     |                        |
#     |      (eDP1)      |                        |
#     +------------------+------------------------+
#   (0,320)
#
# xrandr \
#   --output "$INTERNAL" --auto --pos 0x320 \
#   --output "$EXTERNAL" --auto --pos 1366x0


# =========================================================
# CONFIGURATION 2: External Above Internal (Alternative)
# =========================================================

# @brief Configures External monitor ABOVE Internal monitor.
#
# Places HDMI1 on top, slightly offset to center it (x=256).
# Assumes External height is 1080px.
#
# **Screen Layout Illustration:**
#
#             x=256, y=0
#              +--------------------------+
#              |                          |
#              |     EXTERNAL (HDMI1)     |
#              |                          |
#              +--------------------------+
#     x=0, y=1080
#   +---------------------------+
#   |                           |
#   |      INTERNAL (eDP1)      |
#   |                           |
#   +---------------------------+
#
xrandr \
  --output "$INTERNAL" --auto --pos 0x1080 \
  --output "$EXTERNAL" --auto --pos 256x0
