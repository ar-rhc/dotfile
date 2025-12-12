#!/bin/bash

source "$CONFIG_DIR/colors.sh"

# Dato integration for proper date/time display
dato=(
  icon.drawing=off
  label.width=120
  label.align=right
  label.font="0xProto Nerd Font Mono:Bold:12.0"
  label.padding_left=8
  label.padding_right=8
  padding_left=15
  padding_right=15
  update_freq=30
  script="$PLUGIN_DIR/dato.sh"
  click_script="open -a Dato"
)

sketchybar --add item dato right       \
           --set dato "${dato[@]}" \
           --subscribe dato system_woke
