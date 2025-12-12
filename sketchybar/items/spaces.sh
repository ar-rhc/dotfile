#!/bin/sh

#SPACE_ICONS=("1" "2" "3" "4")

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

# ============================================================
# Workspace Ordering Configuration
# ============================================================
# Set to "custom" to use custom order, "default" to use AeroSpace's default order
USE_CUSTOM_ORDER="custom"
# USE_CUSTOM_ORDER="default"  # Uncomment this line and comment above to use default order

# Custom workspace order (only used if USE_CUSTOM_ORDER="custom")
# Default order: alphabetical/numeric as returned by AeroSpace
CUSTOM_WORKSPACE_ORDER="1 2 3 Q W E A S D Z X C M"
# ============================================================

sketchybar --add event aerospace_workspace_change
#echo $(aerospace list-workspaces --monitor 1 --visible no --empty no) >> ~/aaaa

# Function to get ordered workspaces
get_ordered_workspaces() {
  local monitor=$1
  local all_workspaces=$(aerospace list-workspaces --monitor $monitor)
  
  if [ "$USE_CUSTOM_ORDER" = "custom" ]; then
    local ordered=""
    local added=""
    
    # First, add workspaces in custom order (case-insensitive matching)
    for ws in $CUSTOM_WORKSPACE_ORDER; do
      # Find the actual workspace name (preserving case) that matches
      local actual_ws=$(echo "$all_workspaces" | grep -i "^$ws$" | head -1)
      if [ -n "$actual_ws" ]; then
        ordered="$ordered $actual_ws"
        added="$added $actual_ws"
      fi
    done
    
    # Then add any remaining workspaces not in custom order
    for ws in $all_workspaces; do
      # Check if this workspace was already added (using word boundaries)
      local already_added=false
      for added_ws in $added; do
        if [ "$added_ws" = "$ws" ]; then
          already_added=true
          break
        fi
      done
      # If not already added and not in custom order, add it
      if [ "$already_added" = "false" ] && ! echo "$CUSTOM_WORKSPACE_ORDER" | grep -qi "^$ws$"; then
        ordered="$ordered $ws"
      fi
    done
    
    echo $ordered
  else
    # Default order: return as-is from AeroSpace
    echo $all_workspaces
  fi
}

for m in $(aerospace list-monitors | awk '{print $1}'); do
  for i in $(get_ordered_workspaces $m); do
    sid=$i
    space=(
      space="$sid"
      icon="$sid"
      icon.highlight_color=$ORANGE
      icon.padding_left=10
      icon.padding_right=10
      display=$m
      padding_left=2
      padding_right=2
      label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:16.0"
      label.y_offset=-1
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid aerospace_workspace_change display_change system_woke mouse.clicked mouse.entered mouse.exited

    apps=$(aerospace list-windows --workspace $sid | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

    icon_strip=" "
    if [ "${apps}" != "" ]; then
      while read -r app
      do
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
      done <<< "${apps}"
    else
      icon_strip=" —"
    fi

    sketchybar --set space.$sid label="$icon_strip"
  done

  for i in $(aerospace list-workspaces --monitor $m --empty); do
    sketchybar --set space.$i display=0
  done
  
done


space_creator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  #click_script='yabai -m space --create'
  script="$PLUGIN_DIR/space_windows.sh"
  #script="$PLUGIN_DIR/aerospace.sh"
  icon.color=$WHITE
)

# sketchybar --add item space_creator left               \
#            --set space_creator "${space_creator[@]}"   \
#            --subscribe space_creator space_windows_change



sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"   \
           --subscribe space_creator aerospace_workspace_change




# sketchybar  --add item change_windows left \
#             --set change_windows script="$PLUGIN_DIR/change_windows.sh" \
#             --subscribe change_windows space_changes
