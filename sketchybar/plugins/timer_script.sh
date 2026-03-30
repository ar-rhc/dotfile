#!/usr/bin/env bash

PLUGIN_DIR="$CONFIG_DIR/plugins"

case "$SENDER" in
"mouse.entered")
  sketchybar --set timer popup.drawing=on
  ;;
"mouse.exited" | "mouse.exited.global")
  sketchybar --set timer popup.drawing=off
  ;;
*)
  python3 "$PLUGIN_DIR/pomodoro.py" tick
  ;;
esac
