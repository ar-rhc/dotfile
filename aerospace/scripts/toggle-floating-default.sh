#!/bin/bash

CONFIG="$HOME/dotfiles/aerospace/aerospace.toml"
APP_ID=$(aerospace list-windows --focused --format '%{app-bundle-id}' 2>/dev/null)
APP_NAME=$(aerospace list-windows --focused --format '%{app-name}' 2>/dev/null)

if [ -z "$APP_ID" ]; then
  exit 1
fi

# Check if a simple floating rule exists for this app
# Simple = has app-id match + run = ['layout floating'] with no window-title-regex
# We look for the pattern:
#   [[on-window-detected]]
#   if.app-id = 'com.example.app'
#   run = ['layout floating']
FOUND=$(awk -v id="$APP_ID" '
  /^\[\[on-window-detected\]\]/ {
    start = NR; block = $0 "\n"; next
  }
  start && /^if\.app-id/ {
    block = block $0 "\n"
    if ($0 ~ id) { has_id = 1 } else { has_id = 0 }
    next
  }
  start && /^if\.window-title-regex/ {
    has_id = 0; start = 0; next
  }
  start && has_id && /^run = \[.layout floating.\]/ {
    print start ":" NR
    start = 0; has_id = 0; next
  }
  start && /^run =/ {
    start = 0; has_id = 0; next
  }
  /^\[/ && !/^\[\[on-window-detected\]\]/ {
    start = 0; has_id = 0
  }
' "$CONFIG")

if [ -n "$FOUND" ]; then
  # Remove the rule — extract line range
  START_LINE=$(echo "$FOUND" | head -1 | cut -d: -f1)
  END_LINE=$(echo "$FOUND" | head -1 | cut -d: -f2)

  # Also remove blank lines immediately before the block
  while [ "$START_LINE" -gt 1 ]; do
    PREV=$((START_LINE - 1))
    PREV_CONTENT=$(sed -n "${PREV}p" "$CONFIG")
    if [ -z "$PREV_CONTENT" ]; then
      START_LINE=$PREV
    else
      break
    fi
  done

  sed -i '' "${START_LINE},${END_LINE}d" "$CONFIG"
  STATE="tile"
else
  # Add the rule
  printf '\n[[on-window-detected]]\nif.app-id = '\''%s'\''\nrun = ['\''layout floating'\'']\n' "$APP_ID" >> "$CONFIG"
  STATE="float"
fi

# Reload aerospace config
aerospace reload-config 2>/dev/null

# Kill any pending restore from a previous toggle
PID_FILE="/tmp/sketchybar_service_mode_restore.pid"
if [ -f "$PID_FILE" ]; then
  kill $(cat "$PID_FILE") 2>/dev/null
  rm -f "$PID_FILE"
fi

# Show state in SketchyBar service_mode item
if [ "$STATE" = "float" ]; then
  ICON="􀢌"
else
  ICON="􀧍"
fi

sketchybar --set service_mode \
  icon="$ICON" \
  icon.drawing=on \
  label="$APP_NAME: $(echo "$STATE" | awk '{print toupper(substr($0,1,1)) substr($0,2)}')" \
  label.drawing=on \
  width=-1

# Restore to service mode active state after 4s
(sleep 4 && sketchybar --set service_mode \
  icon=􃎣 \
  icon.drawing=on \
  label.drawing=off \
  width=dynamic && rm -f "$PID_FILE") &
echo $! > "$PID_FILE"
