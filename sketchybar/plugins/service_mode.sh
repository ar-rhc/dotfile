#!/bin/bash

source "$CONFIG_DIR/colors.sh"

CHEAT_ITEMS="cheat.f cheat.d cheat.t cheat.e cheat.s cheat.w cheat.+/- cheat.g cheat.r cheat.c cheat.hjkl cheat.esc"
APP_CHEAT_ITEMS="appcheat.Q appcheat.W appcheat.E appcheat.T appcheat.F appcheat.B appcheat.Z appcheat.M appcheat.ESC"
HIDE_ITEMS="menu_trigger space_creator timer volume_desktop volume_desktop_slider notifications input_source trash next_event wifi weather music"

hide_items() {
  for item in $HIDE_ITEMS; do
    sketchybar --set "$item" drawing=off 2>/dev/null
  done
  sketchybar --query bar 2>/dev/null | python3 -c "
import sys, json, subprocess
items = json.load(sys.stdin).get('items', [])
for i in items:
    if i.startswith('space.') or i.startswith('notif.'):
        subprocess.run(['sketchybar', '--set', i, 'drawing=off'], capture_output=True)
"
}

show_items() {
  for item in $HIDE_ITEMS; do
    sketchybar --set "$item" drawing=on 2>/dev/null
  done
  sketchybar --query bar 2>/dev/null | python3 -c "
import sys, json, subprocess
items = json.load(sys.stdin).get('items', [])
for i in items:
    if i.startswith('space.'):
        subprocess.run(['sketchybar', '--set', i, 'drawing=on'], capture_output=True)
"
}

show_cheat() {
  for item in $CHEAT_ITEMS; do
    sketchybar --set "$item" drawing=on 2>/dev/null
  done
}

hide_cheat() {
  for item in $CHEAT_ITEMS; do
    sketchybar --set "$item" drawing=off 2>/dev/null
  done
}

show_app_cheat() {
  for item in $APP_CHEAT_ITEMS; do
    sketchybar --set "$item" drawing=on 2>/dev/null
  done
}

hide_app_cheat() {
  for item in $APP_CHEAT_ITEMS; do
    sketchybar --set "$item" drawing=off 2>/dev/null
  done
}

if [ "$SENDER" = "aerospace_service_mode_enter" ]; then
  sketchybar --bar color=0xa01a4a2a
  sketchybar --set service_mode \
    icon=􃎣 \
    width=dynamic \
    icon.drawing=on
  show_cheat
  hide_app_cheat
  hide_items
elif [ "$SENDER" = "aerospace_service_mode_exit" ]; then
  sketchybar --bar color=$BAR_COLOR
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
  hide_cheat
  hide_app_cheat
  show_items
elif [ "$SENDER" = "aerospace_app_mode_enter" ]; then
  sketchybar --bar color=0xa04a1a4a
  sketchybar --set service_mode \
    icon=􃎺 \
    width=dynamic \
    icon.drawing=on
  hide_cheat
  show_app_cheat
  hide_items
elif [ "$SENDER" = "aerospace_app_mode_exit" ]; then
  sketchybar --bar color=$BAR_COLOR
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
  hide_cheat
  hide_app_cheat
  show_items
fi
