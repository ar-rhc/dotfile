#!/bin/sh

volume_desktop=(
  icon=$VOLUME_100
  icon.font="$FONT:Regular:14.0"
  label.drawing=off
  padding_left=5
  update_freq=5
  script="$PLUGIN_DIR/volume_desktop.sh"
  click_script="$PLUGIN_DIR/volume_desktop_click.sh"
)

volume_desktop_slider=(
  icon.drawing=off
  label.drawing=off
  slider.highlight_color=$BLUE
  slider.background.height=5
  slider.background.corner_radius=3
  slider.background.color=$BACKGROUND_2
  slider.knob=􀀁
  slider.knob.drawing=on
  slider.width=0
  padding_left=0
  padding_right=0
  script="$PLUGIN_DIR/volume_desktop_slider.sh"
  updates=on
)

sketchybar --add item volume_desktop right \
           --set volume_desktop "${volume_desktop[@]}" \
           --subscribe volume_desktop volume_change system_woke mouse.entered mouse.exited.global \
           --add slider volume_desktop_slider right \
           --set volume_desktop_slider "${volume_desktop_slider[@]}" \
           --subscribe volume_desktop_slider mouse.clicked mouse.entered mouse.exited.global
