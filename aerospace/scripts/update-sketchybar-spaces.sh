#!/bin/bash

# Update sketchybar spaces after workspace change
# This script triggers the aerospace_workspace_change event in sketchybar
# to ensure all space indicators are updated with current workspace state
#
# How it works with sketchybar plugins:
# - space.sh: Listens to aerospace_workspace_change and updates ALL workspace icons
# - space_windows.sh: Uses AEROSPACE_FOCUSED_WORKSPACE and AEROSPACE_PREV_WORKSPACE
#   to update highlights and reload icons for both previous and current workspaces

# State file to track previous workspace
STATE_FILE="${HOME}/.config/aerospace/.last_workspace"
STATE_DIR="${HOME}/.config/aerospace"

# Ensure state directory exists
mkdir -p "$STATE_DIR" 2>/dev/null

# Get current focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused --format "%{workspace}" 2>/dev/null)

# Exit early if we can't get current workspace
if [ -z "$FOCUSED_WORKSPACE" ]; then
    exit 1
fi

# Get previous workspace from state file, or use current if file doesn't exist
if [ -f "$STATE_FILE" ]; then
    PREV_WORKSPACE=$(cat "$STATE_FILE" 2>/dev/null | tr -d '\n')
    # If file is empty or invalid, use current workspace
    [ -z "$PREV_WORKSPACE" ] && PREV_WORKSPACE="$FOCUSED_WORKSPACE"
else
    # First run: no previous workspace, use current
    # This ensures space_windows.sh can still update the focused workspace highlight
    PREV_WORKSPACE="$FOCUSED_WORKSPACE"
fi

# Always trigger update (space.sh's update_all_spaces_icons handles efficiency)
# This ensures window icons are always up-to-date, even if workspace didn't change
# (e.g., windows moved within same workspace, or app launched/closed)

# Trigger sketchybar update with workspace change event
# Format matches aerospace.toml exec-on-workspace-change for consistency
# The variables are passed as environment variables to the triggered event
/opt/homebrew/bin/sketchybar --trigger aerospace_workspace_change \
  AEROSPACE_FOCUSED_WORKSPACE="$FOCUSED_WORKSPACE" \
  AEROSPACE_PREV_WORKSPACE="$PREV_WORKSPACE" 2>/dev/null

# Also trigger window_moved event to ensure window icons are updated
# This is handled by space.sh which calls update_all_spaces_icons()
/opt/homebrew/bin/sketchybar --trigger window_moved 2>/dev/null

# Save current workspace as previous for next time
# Only update if workspace actually changed to avoid unnecessary file writes
if [ "$FOCUSED_WORKSPACE" != "$PREV_WORKSPACE" ]; then
    echo "$FOCUSED_WORKSPACE" > "$STATE_FILE" 2>/dev/null
fi

