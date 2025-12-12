#!/bin/bash

if [ "$SENDER" = "aerospace_service_mode_enter" ]; then
  sketchybar --set service_mode \
    icon=􃎣 \
    width=dynamic \
    icon.drawing=on
elif [ "$SENDER" = "aerospace_service_mode_exit" ]; then
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
elif [ "$SENDER" = "aerospace_app_mode_enter" ]; then
  sketchybar --set service_mode \
    icon=􃎺\
    width=dynamic \
    icon.drawing=on
elif [ "$SENDER" = "aerospace_app_mode_exit" ]; then
  sketchybar --set service_mode \
    width=0 \
    icon.drawing=off
fi
