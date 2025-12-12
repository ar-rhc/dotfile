#!/bin/bash

# This script handles aerospace events and updates sketchybar accordingly

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"

# Function to refresh aerospace workspaces
refresh_aerospace_workspaces() {
  # Run the aerospace workspace script to update displays
  "$CONFIG_DIR/items/aerospace.sh" &
}

# Handle different types of events
case "$SENDER" in
  "aerospace_workspace_change"|"window_focus"|"space_change") 
    refresh_aerospace_workspaces
    ;;
  *) 
    refresh_aerospace_workspaces
    ;;
esac