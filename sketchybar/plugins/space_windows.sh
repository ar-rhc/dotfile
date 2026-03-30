#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

AEROSPACE_FOCUSED_MONITOR=$(aerospace list-monitors --focused | awk '{print $1}')
AEROSPACE_WORKSPACE_FOCUSED_MONITOR=$(aerospace list-workspaces --monitor focused --empty no)
AEROSPACE_EMPTY_WORKSPACE=$(aerospace list-workspaces --monitor focused --empty)

# Set space display for all current monitors (used on workspace change and display connect/disconnect)
# 2 monitors: AeroSpace order differs from SketchyBar (swap 1<->2). 3+ monitors: use direct mapping.
refresh_space_displays() {
  monitors=$(aerospace list-monitors 2>/dev/null | awk '{print $1}')
  num_monitors=$(echo "$monitors" | wc -w | tr -d ' ')
  for m in $monitors; do
    if [ "$num_monitors" -eq 2 ]; then
      sketchy_display=$((3 - m))
    else
      sketchy_display=$m
    fi
    for w in $(aerospace list-workspaces --monitor "$m" --empty no 2>/dev/null); do
      sketchybar --set space."$w" display="$sketchy_display" 2>/dev/null || true
    done
    FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
    for w in $(aerospace list-workspaces --monitor "$m" --empty 2>/dev/null); do
      if [ "$w" = "$FOCUSED" ]; then
        sketchybar --set space."$w" display="$sketchy_display" 2>/dev/null || true
      else
        sketchybar --set space."$w" display=0 2>/dev/null || true
      fi
    done
  done
}

reload_workspace_icon() {
  # echo reload_workspace_icon "$@" >> ~/aaaa
  apps=$(aerospace list-windows --workspace "$@" | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=""  # Empty string for empty workspaces - only show space number
  fi

  sketchybar --animate sin 10 --set space.$@ label="$icon_strip"
}

if [ "$SENDER" = "aerospace_workspace_change" ]; then

  # if [ $i = "$FOCUSED_WORKSPACE" ]; then
  #   sketchybar --set space.$FOCUSED_WORKSPACE background.drawing=on
  # else
  #   sketchybar --set space.$FOCUSED_WORKSPACE background.drawing=off
  # fi
  #echo 'space_windows_change: '$AEROSPACE_FOCUSED_WORKSPACE >> ~/aaaa
  #echo space: $space >> ~/aaaa
  #space="$(echo "$INFO" | jq -r '.space')"
  #apps="$(echo "$INFO" | jq -r '.apps | keys[]')"
  # apps=$(aerospace list-windows --workspace $AEROSPACE_FOCUSED_WORKSPACE | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')
  #
  # icon_strip=" "
  # if [ "${apps}" != "" ]; then
  #   while read -r app
  #   do
  #     icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
  #   done <<< "${apps}"
  # else
  #   icon_strip=" —"
  # fi

  reload_workspace_icon "$AEROSPACE_PREV_WORKSPACE"
  reload_workspace_icon "$AEROSPACE_FOCUSED_WORKSPACE"

  #sketchybar --animate sin 10 --set space.$space label="$icon_strip"

  # Add animation when workspace becomes focused
  sketchybar --animate sin 10 \
    --set space.$AEROSPACE_FOCUSED_WORKSPACE \
    y_offset=5 y_offset=0 \
    background.drawing=on

  # current workspace space border color
  sketchybar --set space.$AEROSPACE_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY

  # prev workspace space border color
  sketchybar --set space.$AEROSPACE_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2

  # Refresh display for every space on all current monitors (fixes two-monitor and disconnect)
  refresh_space_displays

fi

if [ "$SENDER" = "display_change" ]; then
  refresh_space_displays
fi
