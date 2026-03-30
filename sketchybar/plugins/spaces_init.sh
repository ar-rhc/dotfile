#!/bin/bash
# Called at init time by spaces.lua to create space items
# This needs to be shell because AeroSpace CLI queries are required

source "$CONFIG_DIR/colors.sh"

CUSTOM_WORKSPACE_ORDER="1 2 3 Q W E A S D Z X C M"

get_ordered_workspaces() {
  local monitor=$1
  local all_workspaces=$(aerospace list-workspaces --monitor $monitor)
  local ordered="" added=""
  for ws in $CUSTOM_WORKSPACE_ORDER; do
    local actual_ws=$(echo "$all_workspaces" | grep -i "^$ws$" | head -1)
    if [ -n "$actual_ws" ]; then
      ordered="$ordered $actual_ws"
      added="$added $actual_ws"
    fi
  done
  for ws in $all_workspaces; do
    local already_added=false
    for added_ws in $added; do
      [ "$added_ws" = "$ws" ] && already_added=true && break
    done
    [ "$already_added" = "false" ] && ordered="$ordered $ws"
  done
  echo $ordered
}

monitors=$(aerospace list-monitors | awk '{print $1}')
num_monitors=$(echo "$monitors" | wc -w | tr -d ' ')

for m in $monitors; do
  if [ "$num_monitors" -eq 2 ]; then sketchy_display=$((3 - m)); else sketchy_display=$m; fi
  for sid in $(get_ordered_workspaces $m); do
    sketchybar --add space space.$sid left \
               --set space.$sid \
                 space="$sid" \
                 icon="$sid" \
                 icon.highlight_color=$ORANGE \
                 icon.padding_left=10 \
                 icon.padding_right=10 \
                 display=$sketchy_display \
                 padding_left=2 \
                 padding_right=2 \
                 label.padding_right=20 \
                 label.color=$GREY \
                 label.highlight_color=$WHITE \
                 label.font="sketchybar-app-font:Regular:16.0" \
                 label.y_offset=-1 \
                 background.color=$BACKGROUND_1 \
                 background.border_color=$BACKGROUND_2 \
                 script="$CONFIG_DIR/plugins/space.sh" \
               --subscribe space.$sid aerospace_workspace_change display_change system_woke mouse.clicked mouse.entered mouse.exited

    apps=$(aerospace list-windows --workspace $sid | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
    icon_strip=" "
    if [ -n "$apps" ]; then
      while read -r app; do
        icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
      done <<< "$apps"
    else
      icon_strip=" —"
    fi
    sketchybar --set space.$sid label="$icon_strip"
  done

  for i in $(aerospace list-workspaces --monitor $m --empty); do
    sketchybar --set space.$i display=0
  done
done
