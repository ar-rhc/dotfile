#!/bin/bash

# Register events first
sketchybar --add event aerospace_service_mode_enter
sketchybar --add event aerospace_service_mode_exit
sketchybar --add event aerospace_app_mode_enter
sketchybar --add event aerospace_app_mode_exit

service_mode=(
  icon=􃎣
  icon.font="$FONT:Regular:14.0"
  icon.color=$WHITE
  width=0
  padding_left=5
  padding_right=5
  icon.drawing=off
  label.drawing=off
  background.drawing=off
  script="$PLUGIN_DIR/service_mode.sh"
)

cheat_key=(
  drawing=off
  icon.font="$FONT:Bold:12.0"
  icon.color=$WHITE
  icon.padding_left=8
  icon.padding_right=2
  label.font="$FONT:Regular:12.0"
  label.color=$GREY
  label.padding_left=2
  label.padding_right=8
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.corner_radius=9
  background.height=26
  padding_left=2
  padding_right=2
)

CHEAT_KEYS="f:float d:default t:layout e:equal s:split w:close +/-:size g:gaps r:reset c:empty hjkl:join esc:exit"
APP_CHEAT_KEYS="Q::weather: W::wechat: E::microsoft_edge: T::iterm: F::finder: B::bettertouchtool: Z::zotero: M::mail: ESC:Exit"

sketchybar --add item service_mode center \
           --set service_mode "${service_mode[@]}" \
           --subscribe service_mode aerospace_service_mode_enter aerospace_service_mode_exit aerospace_app_mode_enter aerospace_app_mode_exit

for entry in $CHEAT_KEYS; do
  key="${entry%%:*}"
  action="${entry#*:}"
  sketchybar --add item "cheat.$key" left \
             --set "cheat.$key" "${cheat_key[@]}" icon="$key" label="$action"
done

for entry in $APP_CHEAT_KEYS; do
  key="${entry%%:*}"
  action="${entry#*:}"
  sketchybar --add item "appcheat.$key" left \
             --set "appcheat.$key" "${cheat_key[@]}" icon="$key" label="$action" \
             label.font="sketchybar-app-font:Regular:18.0" \
             label.color=0xffffffff \
             icon.padding_right=6 label.padding_left=6
done
# esc doesn't use app font
sketchybar --set appcheat.esc label.font="$FONT:Regular:12.0"
