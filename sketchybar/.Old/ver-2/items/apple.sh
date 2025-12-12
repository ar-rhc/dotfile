#!/bin/bash

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

apple_logo=(
  icon="􀣺"
  icon.font="SF Pro Mono:Bold:18.0"
  icon.color=0xff50fa7b
  label=""
  label.font="SF Pro Mono:Bold:16.0"
  label.color=0xffffffff
  padding_right=15
  padding_left=10
  click_script="$POPUP_CLICK_SCRIPT"
  popup.align=left
  popup.height=80
)

apple_prefs=(
  icon="⚙️"
  label="System Preferences"
  label.font="SF Pro Mono:Bold:12.0"
  label.color=0xffffffff
  icon.font="SF Pro Mono:Bold:14.0"
  icon.color=0xffffffff
  padding_left=10
  padding_right=10
  background.height=25
  click_script="open 'x-apple.systempreferences:'; $POPUP_OFF"
)

apple_activity=(
  icon="📊"
  label="Activity Monitor"
  label.font="SF Pro Mono:Bold:12.0"
  label.color=0xffffffff
  icon.font="SF Pro Mono:Bold:14.0"
  icon.color=0xffffffff
  padding_left=10
  padding_right=10
  background.height=25
  click_script="open -a 'Activity Monitor'; $POPUP_OFF"
)

apple_lock=(
  icon="🔒"
  label="Lock Screen"
  label.font="SF Pro Mono:Bold:12.0"
  label.color=0xffffffff
  icon.font="SF Pro Mono:Bold:14.0"
  icon.color=0xffffffff
  padding_left=10
  padding_right=10
  background.height=25
  click_script="pmset displaysleepnow; $POPUP_OFF"
)

sketchybar --add item apple.logo left                  \
           --set apple.logo "${apple_logo[@]}"         \
                                                       \
           --add item apple.prefs popup.apple.logo     \
           --set apple.prefs "${apple_prefs[@]}"       \
                                                       \
           --add item apple.activity popup.apple.logo  \
           --set apple.activity "${apple_activity[@]}" \
                                                       \
           --add item apple.lock popup.apple.logo      \
           --set apple.lock "${apple_lock[@]}"