#!/usr/bin/env bash

case "$SENDER" in
"mouse.entered")
  sketchybar --set timer popup.drawing=on
  ;;
"mouse.exited" | "mouse.exited.global")
  sketchybar --set timer popup.drawing=off
  ;;
"reset_timer")
  # Kill any running timer.py processes
  pgrep -f "$PLUGIN_DIR/timer.py" >/dev/null 2>&1 && pgrep -f "$PLUGIN_DIR/timer.py" | xargs -r kill
  # Clear timer label
  sketchybar --set timer label=""
  ;;
esac





