#!/bin/bash

# Simple Apple Music now playing item for SketchyBar.
# Relies on a small Swift monitor that writes track info to /tmp/music_info.txt.

INFO_FILE="/tmp/music_info.txt"
MONITOR_BIN="$PLUGIN_DIR/music/music_monitor_file"
ITEM_NAME="${NAME:-music}"

# Hide item if Music is not running.
if ! pgrep -x Music >/dev/null; then
  sketchybar --set "$ITEM_NAME" drawing=off
  exit 0
fi

# Ensure the Swift monitor is alive.
if ! pgrep -f "$MONITOR_BIN" >/dev/null; then
  "$MONITOR_BIN" >/dev/null 2>&1 &
  sleep 1
fi

if [[ -s "$INFO_FILE" ]]; then
  title=$(grep "^title:" "$INFO_FILE" | cut -d: -f2- | xargs)
  artist=$(grep "^artist:" "$INFO_FILE" | cut -d: -f2- | xargs)
  state=$(grep "^state:" "$INFO_FILE" | cut -d: -f2- | xargs)

  if [[ -n "$title" ]]; then
    icon="􀊖"
    [[ "$state" == "Paused" ]] && icon="􀊘"

    [[ ${#title} -gt 20 ]] && title="${title:0:20}…"
    [[ ${#artist} -gt 15 ]] && artist="${artist:0:15}…"

    label="$title"
    [[ -n "$artist" ]] && label="$title - $artist"

    sketchybar --set "$ITEM_NAME" icon="$icon" label="$label" drawing=on
  else
    sketchybar --set "$ITEM_NAME" drawing=off
  fi
else
  sketchybar --set "$ITEM_NAME" drawing=off
fi

