#!/bin/bash

# Background watcher for aerospace workspace changes
# This runs continuously and watches for aerospace changes

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

# Watch for aerospace workspace changes every 2 seconds
while true; do
  # Check if aerospace is running
  if command -v aerospace >/dev/null 2>&1; then
    # Trigger an update
    sketchybar --trigger aerospace_workspace_change >/dev/null 2>&1
  fi
  sleep 2
done