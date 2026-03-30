#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  # Show the focused app's icon using sketchybar-app-font via icon_map
  mapped_icon=$("$CONFIG_DIR/plugins/icon_map.sh" "$INFO")
  sketchybar --set "$NAME" label="$INFO" \
                           icon="$mapped_icon" \
                           icon.font="sketchybar-app-font:Regular:16.0"
fi
