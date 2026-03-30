#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

# Toggle between icon_map and original app icon
# Set to "icon_map" to use mapped icons (e.g., :arc:, :cursor:)
# Set to "original" to use the original app icon
#USE_ICON_MAP="original"
USE_ICON_MAP="icon_map"  # Uncomment this line and comment above to use icon_map

AEROSPACE_FOCUSED_MONITOR_NO=$(aerospace list-workspaces --focused)
AEROSPACE_LIST_OF_WINDOWS_IN_FOCUSED_MONITOR=$(aerospace list-windows --workspace $AEROSPACE_FOCUSED_MONITOR_NO | awk -F'|' '{gsub(/^ *| *$/, "", $2); print $2}')

if [ "$SENDER" = "front_app_switched" ]; then
  #echo name:$NAME INFO: $INFO SENDER: $SENDER, SID: $SID >> ~/aaaa
  
  # Set icon based on toggle
  if [ "$USE_ICON_MAP" = "icon_map" ]; then
    # Use icon_map to get mapped icon
    mapped_icon=$("$CONFIG_DIR/plugins/icon_map.sh" "$INFO")
    sketchybar --set "$NAME" label="$INFO" icon="$mapped_icon" icon.font="sketchybar-app-font:Regular:16.0" icon.background.drawing=off
  else
    # Use original app icon
  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.8
  fi

  apps=$AEROSPACE_LIST_OF_WINDOWS_IN_FOCUSED_MONITOR
  icon_strip=" "
  if [ "${apps}" != "" ]; then
    while read -r app
    do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "${apps}"
  else
    icon_strip=" —"
  fi
  sketchybar --set space.$AEROSPACE_FOCUSED_MONITOR_NO label="$icon_strip"
fi
