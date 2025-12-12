#!/bin/bash

CONFIG_DIR="${CONFIG_DIR:-$HOME/.config/sketchybar}"
source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/helpers/icon_map.sh"

aerospace_spaces() {
  # Get focused workspace for each monitor
  FOCUSED_1=$(aerospace list-workspaces --monitor 1 --focused 2>/dev/null | head -1)
  FOCUSED_2=$(aerospace list-workspaces --monitor 2 --focused 2>/dev/null | head -1)
  FOCUSED_3=$(aerospace list-workspaces --monitor 3 --focused 2>/dev/null | head -1)

  args=()
  
  # Remove all existing workspace items
  for i in {1..11}; do
    args+=(--remove aerospace.workspace.$i)
  done

  # Helper function to create workspace item
  create_workspace_item() {
    local workspace=$1
    local display_id=$2
    local focused_ws=$3
    
    # Get app icon for this workspace
    local APP=$(aerospace list-windows --workspace "$workspace" --format '%{app-name}' 2>/dev/null | head -1)
    local ICON_RESULT
    local ICON_DRAWING="on"
    local ICON_FONT="sketchybar-app-font:Regular:16.0"
    
    if [ -n "$APP" ]; then
      __icon_map "$APP"
      ICON_RESULT="$icon_result"
      if [ -z "$ICON_RESULT" ] || [ "$ICON_RESULT" = ":default:" ]; then
        # Use workspace number as icon with regular font if app icon not found
        ICON_RESULT="$workspace"
        ICON_FONT="SF Pro:Semibold:14.0"
      else
        # Use app font for app icons
        ICON_FONT="sketchybar-app-font:Regular:16.0"
      fi
    else
      # For empty workspaces, use workspace number with regular font
      ICON_RESULT="$workspace"
      ICON_FONT="SF Pro:Semibold:14.0"
    fi

    # Set colors based on focus
    if [ "$workspace" = "$focused_ws" ]; then
      local BG_COLOR=$GREEN
      local ICON_COLOR=$BLACK
      local TEXT_COLOR=$BLACK
    else
      local BG_COLOR=$BACKGROUND_2
      local ICON_COLOR=$WHITE
      local TEXT_COLOR=$WHITE
    fi

    # Add workspace item
    args+=(
      --add space aerospace.workspace.$workspace left
      --set aerospace.workspace.$workspace display=$display_id
      --set aerospace.workspace.$workspace icon="$ICON_RESULT"
      --set aerospace.workspace.$workspace icon.drawing="$ICON_DRAWING"
      --set aerospace.workspace.$workspace icon.padding_left=8
      --set aerospace.workspace.$workspace icon.padding_right=4
      --set aerospace.workspace.$workspace icon.color="$ICON_COLOR"
      --set aerospace.workspace.$workspace icon.font="$ICON_FONT"
      --set aerospace.workspace.$workspace label="$workspace"
      --set aerospace.workspace.$workspace label.padding_left=4
      --set aerospace.workspace.$workspace label.padding_right=8
      --set aerospace.workspace.$workspace label.color="$TEXT_COLOR"
      --set aerospace.workspace.$workspace label.font="SF Pro:Semibold:13.0"
      --set aerospace.workspace.$workspace background.color="$BG_COLOR"
      --set aerospace.workspace.$workspace background.border_width=0
      --set aerospace.workspace.$workspace background.corner_radius=8
      --set aerospace.workspace.$workspace background.height=28
      --set aerospace.workspace.$workspace background.drawing=on
      --set aerospace.workspace.$workspace click_script="aerospace workspace $workspace"
      --set aerospace.workspace.$workspace script="$PLUGIN_DIR/aerospace_space_click.sh"
    )
  }

  # Monitor 1: Workspaces 1, 2 → Display 1
  create_workspace_item 1 1 "$FOCUSED_1"
  create_workspace_item 2 1 "$FOCUSED_1"

  # Monitor 2: Workspaces 3, 4 → Display 2
  create_workspace_item 3 2 "$FOCUSED_2"
  create_workspace_item 4 2 "$FOCUSED_2"

  # Monitor 3: Workspaces 5, 6 → Display 3
  create_workspace_item 5 3 "$FOCUSED_3"
  create_workspace_item 6 3 "$FOCUSED_3"

  # Apply all changes
  sketchybar "${args[@]}" > /dev/null 2>&1 &
}

case "$SENDER" in
  "aerospace_workspace_change")
    aerospace_spaces
    ;;
  *)
    aerospace_spaces
    ;;
esac
