#!/bin/bash

CHEAT="f:float  d:default  r:reset  c:close  hjkl/←↓↑→:join  esc:exit"

if [ "$SENDER" = "aerospace_service_mode_enter" ]; then
  sketchybar --set service_mode \
    icon=􃎣 \
    width=dynamic \
    icon.drawing=on
  sketchybar --set service_mode_cheat \
    label="$CHEAT" \
    label.drawing=on \
    drawing=on
elif [ "$SENDER" = "aerospace_service_mode_exit" ]; then
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
  sketchybar --set service_mode_cheat \
    drawing=off \
    label.drawing=off
elif [ "$SENDER" = "aerospace_app_mode_enter" ]; then
  sketchybar --set service_mode \
    icon=􃎺 \
    width=dynamic \
    icon.drawing=on
  sketchybar --set service_mode_cheat drawing=off
elif [ "$SENDER" = "aerospace_app_mode_exit" ]; then
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
  sketchybar --set service_mode_cheat drawing=off
fi
