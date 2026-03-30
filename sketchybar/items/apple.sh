#!/bin/bash

apple_logo=(
  icon=$APPLE
  icon.font="$FONT:Black:16.0"
  icon.color=$WHITE
  padding_right=15
  label.drawing=off
  script="$PLUGIN_DIR/apple.sh"
  popup.height=35
  popup.background.border_width=0
)

apple_prefs=(
  icon=$PREFERENCES
  label="Preferences"
  click_script="open -a 'System Preferences'; sketchybar --set apple.logo popup.drawing=off"
)

apple_activity=(
  icon=$ACTIVITY
  label="Activity"
  click_script="open -a 'Activity Monitor'; sketchybar --set apple.logo popup.drawing=off"
)

# AeroSpace quick views
apple_aero_apps=(
  icon=􀫵
  label="Apps List"
  label.max_chars=180
  click_script="$PLUGIN_DIR/aerospace/aerospace_apps.sh"
)

apple_aero_windows=(
  icon=􀏜
  label="Windows List"
  label.max_chars=180
  click_script="$PLUGIN_DIR/aerospace/aerospace_windows.sh"
)

apple_lock=(
  icon=$LOCK
  label="Lock Screen"
  click_script="pmset displaysleepnow; sketchybar --set apple.logo popup.drawing=off"
)

sketchybar --add item apple.logo left                  \
           --set apple.logo "${apple_logo[@]}"         \
           --subscribe apple.logo mouse.entered mouse.exited mouse.exited.global mouse.clicked \
                                                       \
           --add item apple.prefs popup.apple.logo     \
           --set apple.prefs "${apple_prefs[@]}"       \
                                                       \
           --add item apple.activity popup.apple.logo  \
           --set apple.activity "${apple_activity[@]}" \
                                                       \
           --add item apple.aero_apps popup.apple.logo \
           --set apple.aero_apps "${apple_aero_apps[@]}" \
                                                       \
           --add item apple.aero_windows popup.apple.logo \
           --set apple.aero_windows "${apple_aero_windows[@]}" \
                                                       \
           --add item apple.lock popup.apple.logo      \
           --set apple.lock "${apple_lock[@]}"
