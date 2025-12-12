#!/bin/bash

airpods_battery=(
  icon="🎧"
  icon.font="$FONT:Regular:12.0"
  label.font="$FONT:Semibold:11.0"
  padding_left=10
  padding_right=10
  update_freq=300
  script="$PLUGIN_DIR/airpods_battery.sh"
)

sketchybar --add event bluetooth_change "com.apple.bluetooth.status" \
           --add item airpods_battery right \
           --set airpods_battery "${airpods_battery[@]}" \
           --subscribe airpods_battery bluetooth_change
