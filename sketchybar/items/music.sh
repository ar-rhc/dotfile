#!/bin/bash

# Start the music monitor if it is not already running.
if ! pgrep -f "$PLUGIN_DIR/music/music_monitor_file" >/dev/null; then
  "$PLUGIN_DIR/music/music_monitor_file" >/dev/null 2>&1 &
fi

POPUP_OFF='sketchybar --set music popup.drawing=off'

music=(
  script="$PLUGIN_DIR/music/music.sh"
  click_script="$PLUGIN_DIR/music/music_click.sh"
  icon.font="$FONT:Regular:14.0"
  label.font="$FONT:Semibold:13.0"
  update_freq=2
  updates=on
  drawing=off
  popup.height=35
  popup.background.border_width=0
)

# Popup items showing available commands
cmd_playpause=(
  label="Left Click - Play/Pause"
  label2="Play/Pause"
  click_script="$POPUP_OFF"
)

cmd_next=(
  label="Opt + Left Click - Next Track"
  label2="Next Track"
  click_script="$POPUP_OFF"
)

cmd_prev=(
  label="Ctrl + Left Click - Previous Track"
  label2="Previous Track"
  click_script="$POPUP_OFF"
)

cmd_open=(
  label="Cmd + Left Click - Open Music"
  label2="Open Music"
  click_script="$POPUP_OFF"
)

sketchybar --add item music center \
           --set music "${music[@]}" \
           --add item music.cmd_playpause popup.music \
           --set music.cmd_playpause "${cmd_playpause[@]}" \
           --add item music.cmd_next popup.music \
           --set music.cmd_next "${cmd_next[@]}" \
           --add item music.cmd_prev popup.music \
           --set music.cmd_prev "${cmd_prev[@]}" \
           --add item music.cmd_open popup.music \
           --set music.cmd_open "${cmd_open[@]}"

