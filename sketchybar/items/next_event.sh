#!/bin/bash

next_event=(
  icon=""
  #label.font="$FONT:Semibold:11.0"
  padding_left=0
  padding_right=10
  display="active"
  update_freq=60
  script="$PLUGIN_DIR/next_event.sh"
  # Click handler supports multiple actions based on button and modifier keys
  # $BUTTON: left, right, or other
  # $MODIFIER: shift, ctrl, alt, or cmd
  click_script="$PLUGIN_DIR/next_event_click.sh"
)

sketchybar --add item next_event right \
           --set next_event "${next_event[@]}" display=2
