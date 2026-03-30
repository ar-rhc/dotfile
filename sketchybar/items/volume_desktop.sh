#!/bin/sh

volume_desktop=(
  click_script="$PLUGIN_DIR/scripts/volume_desktop_click.sh"
  padding_left=5
  icon=$VOLUME_100
  #icon.color=$GREY
  icon.font="$FONT:Regular:14.0"
  label.drawing=off
)

sketchybar --add item volume_desktop right \
           --set volume_desktop "${volume_desktop[@]}"

