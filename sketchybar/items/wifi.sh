#!/bin/sh

wifi=(
  icon=󰖩
  icon.color=0xff58d1fc
  label.drawing=on
  script="$PLUGIN_DIR/wifi.sh"
  update_freq=30
)

sketchybar --add item wifi right \
           --set wifi "${wifi[@]}" \
           --subscribe wifi wifi_change system_woke
