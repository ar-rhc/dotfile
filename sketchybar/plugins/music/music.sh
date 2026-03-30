#!/bin/bash

# Simple Apple Music now playing item for SketchyBar.
# Relies on a small Swift monitor that writes track info to /tmp/music_info.txt.

INFO_FILE="/tmp/music_info.txt"
MONITOR_BIN="$PLUGIN_DIR/music/music_monitor_file"
ITEM_NAME="${NAME:-music}"

# Handle mouse events for popup
case "$SENDER" in
  "mouse.exited" | "mouse.exited.global")
    sketchybar --set "$ITEM_NAME" popup.drawing=off
    exit 0
    ;;
esac

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

# If Swift monitor hasn't written yet (e.g. Music was already playing at bar load),
# query current state via AppleScript and write to info file so we show something.
if [[ ! -s "$INFO_FILE" ]]; then
  as_state=$(osascript -e 'tell application "Music"
    if player state is playing or player state is paused then
      set t to name of current track
      set a to artist of current track
      set s to player state as string
      return t & "|||" & a & "|||" & s
    end if
  end tell' 2>/dev/null)
  if [[ -n "$as_state" ]]; then
    title="${as_state%%|||*}"
    rest="${as_state#*|||}"
    artist="${rest%%|||*}"
    state="${rest#*|||}"
    printf 'title:%s\nartist:%s\nstate:%s\n' "$title" "$artist" "$state" > "$INFO_FILE"
  fi
fi

if [[ -s "$INFO_FILE" ]]; then
  title=$(grep "^title:" "$INFO_FILE" | cut -d: -f2- | xargs)
  artist=$(grep "^artist:" "$INFO_FILE" | cut -d: -f2- | xargs)
  state=$(grep "^state:" "$INFO_FILE" | cut -d: -f2- | xargs)

  if [[ -n "$title" ]]; then
    icon="􀊖"
    [[ "$state" == "Paused" ]] && icon="􀊘"

    [[ ${#title} -gt 30 ]] && title="${title:0:20}…"
    [[ ${#artist} -gt 25 ]] && artist="${artist:0:15}…"

    label="$title"
    [[ -n "$artist" ]] && label="$title - $artist"

    sketchybar --set "$ITEM_NAME" icon="$icon" label="$label" drawing=on
  else
    sketchybar --set "$ITEM_NAME" drawing=off
  fi
else
  sketchybar --set "$ITEM_NAME" drawing=off
fi

