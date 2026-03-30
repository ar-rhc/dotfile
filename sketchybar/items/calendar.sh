#!/bin/bash

calendar=(
  icon=""  # Icon will be set dynamically by script based on day
  icon.font="$FONT:Black:18.0"
  icon.padding_right=0
  label.align=right
  padding_left=5
  update_freq=60
  script="$PLUGIN_DIR/calendar.sh"
  click_script="$PLUGIN_DIR/zen.sh"
)

sketchybar --add item calendar right       \
           --set calendar "${calendar[@]}" \
           --subscribe calendar system_woke
