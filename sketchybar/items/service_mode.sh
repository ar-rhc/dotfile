#!/bin/bash

# Register events first
sketchybar --add event aerospace_service_mode_enter
sketchybar --add event aerospace_service_mode_exit
sketchybar --add event aerospace_app_mode_enter
sketchybar --add event aerospace_app_mode_exit

service_mode=(
  icon=􃎣
  icon.font="$FONT:Regular:14.0"
  icon.color=$WHITE
  width=0
  padding_left=5
  padding_right=5
  icon.drawing=off
  label.drawing=off
  background.drawing=off
  script="$PLUGIN_DIR/service_mode.sh"
)

sketchybar --add item service_mode center \
           --set service_mode "${service_mode[@]}" \
           --subscribe service_mode aerospace_service_mode_enter aerospace_service_mode_exit aerospace_app_mode_enter aerospace_app_mode_exit
