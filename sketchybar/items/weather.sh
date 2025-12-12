#!/bin/sh

sketchybar --add item weather right \
  --set weather display=2\
  icon=󰖐 \
  script="$PLUGIN_DIR/weather.sh" \
  padding_left=20 \
  
  update_freq=1500 \
  --subscribe weather mouse.clicked

