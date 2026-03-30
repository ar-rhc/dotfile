#!/bin/sh

sketchybar --add item weather right \
  --set weather display=2\
  icon=󰖐 \
  icon.font="Hack Nerd Font:Regular:13.0" \
  script="$PLUGIN_DIR/weather.sh" \
  padding_left=20 \
  update_freq=1800 \
  click_script="$PLUGIN_DIR/scripts/weather_click.sh" \
  --subscribe weather mouse.clicked

