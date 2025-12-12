#!/bin/bash

# Get current workspace
CURRENT_WORKSPACE=$(aerospace list-workspaces --focused)

# Get all workspaces that have windows
ACTIVE_WORKSPACES=($(aerospace list-workspaces --monitor all))

# Remove all existing workspace items
for i in {1..9}; do
  sketchybar --remove aerospace.workspace.$i 2>/dev/null || true
done

# Add only active workspaces
for workspace in "${ACTIVE_WORKSPACES[@]}"; do
  # Get apps in this workspace
  APPS=$(aerospace list-windows --workspace "$workspace" --format '%{app-name}' | head -3 | tr '\n' ' ')
  
  # Get the first app for icon
  FIRST_APP=$(aerospace list-windows --workspace "$workspace" --format '%{app-name}' | head -1)
  
  # Set icon based on first app
  case "$FIRST_APP" in
    "Warp") ICON="󰊠" ;;
    "Arc") ICON="󰀹" ;;
    "Chrome") ICON="󰊯" ;;
    "Safari") ICON="󰀹" ;;
    "Code") ICON="󰨞" ;;
    "Visual Studio Code") ICON="󰨞" ;;
    "Terminal") ICON="󰆍" ;;
    "Finder") ICON="󰀶" ;;
    "Slack") ICON="󰒱" ;;
    "Discord") ICON="󰙯" ;;
    "Spotify") ICON="󰓇" ;;
    "Mail") ICON="󰇮" ;;
    "Calendar") ICON="󰃭" ;;
    "Notes") ICON="󱞎" ;;
    "System Preferences") ICON="󰒓" ;;
    "System Settings") ICON="󰒓" ;;
    *) ICON="$workspace" ;;
  esac
  
  # Create label with workspace number and apps
  if [ -n "$APPS" ]; then
    LABEL="$workspace"
  else
    LABEL="$workspace"
  fi
  
  # Set colors based on current workspace
  if [ "$workspace" = "$CURRENT_WORKSPACE" ]; then
    BG_COLOR="0xffff6d00"
    ICON_COLOR="0xff000000"
    LABEL_COLOR="0xff000000"
  else
    BG_COLOR="0x40ffffff"
    ICON_COLOR="0xffffffff"
    LABEL_COLOR="0xffffffff"
  fi
  
  # Add the workspace item
  sketchybar --add item aerospace.workspace.$workspace left \
             --set aerospace.workspace.$workspace \
                   icon="$ICON" \
                   label="$LABEL" \
                   icon.padding_left=8 \
                   icon.padding_right=4 \
                   label.padding_left=0 \
                   label.padding_right=8 \
                   background.color="$BG_COLOR" \
                   background.corner_radius=6 \
                   background.height=28 \
                   icon.color="$ICON_COLOR" \
                   label.color="$LABEL_COLOR" \
                   label.font="SF Pro:Bold:12.0" \
                   click_script="aerospace workspace $workspace"
done