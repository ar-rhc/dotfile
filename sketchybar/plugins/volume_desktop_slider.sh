#!/bin/bash

source "$CONFIG_DIR/icons.sh"

case "$SENDER" in
  "mouse.entered")
    sketchybar --set volume_desktop_slider slider.width=100
    ;;
  "mouse.exited.global")
    sketchybar --animate tanh 30 --set volume_desktop_slider slider.width=0
    ;;
  "mouse.clicked")
    # Set volume from slider position (PERCENTAGE is 0-100)
    VOL=$(python3 -c "print(${PERCENTAGE:-50} / 100.0)")
    betterdisplaycli set -n=LG --volume="$VOL"

    # Update icon
    if [ "${PERCENTAGE:-0}" -le 0 ]; then
      ICON=$VOLUME_0
    elif [ "$PERCENTAGE" -le 15 ]; then
      ICON=$VOLUME_10
    elif [ "$PERCENTAGE" -le 40 ]; then
      ICON=$VOLUME_33
    elif [ "$PERCENTAGE" -le 65 ]; then
      ICON=$VOLUME_66
    else
      ICON=$VOLUME_100
    fi
    sketchybar --set volume_desktop icon="$ICON"
    ;;
esac
