#!/bin/bash

source "$CONFIG_DIR/icons.sh"

# Toggle mute via BetterDisplay
betterdisplaycli toggle -n=LG --mute

MUTE=$(betterdisplaycli get -n=LG --mute 2>/dev/null)
if [ "$MUTE" = "on" ]; then
  sketchybar --set volume_desktop icon="$VOLUME_0"
else
  sketchybar --set volume_desktop icon="$VOLUME_100"
fi
