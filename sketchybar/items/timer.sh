#!/usr/bin/env bash

# Timer item with popup presets and stopwatch
sketchybar --add event reset_timer


# Main timer item
 timer=(
  icon="􁙆"
  script="$PLUGIN_DIR/reset_timer.sh"
  click_script="sketchybar --set timer popup.drawing=toggle; sketchybar --trigger reset_timer"
  popup.background.border_width=0
  padding_left=10
 )

 # Stopwatch mode
 stopwatch=(
  label="SW Mode"
  click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py"
 )

 # Presets
 preset1=(label="3 min"  click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 180")
 preset2=(label="5 min"  click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 300")
 preset3=(label="10 min" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 600")
 preset4=(label="15 min" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 900")
 preset5=(label="20 min" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 1200")
 preset6=(label="30 min" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 1800")
 preset7=(label="45 min" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 2700")
 preset8=(label="1 hour" click_script="sketchybar --set timer popup.drawing=toggle; python3 $PLUGIN_DIR/timer.py 3600")

sketchybar --add item timer left \
           --set timer "${timer[@]}" \
           --subscribe timer reset_timer \
           --add item timer.stopwatch popup.timer \
           --set timer.stopwatch "${stopwatch[@]}" \
           --add item timer.preset1 popup.timer \
           --set timer.preset1 "${preset1[@]}" \
           --add item timer.preset2 popup.timer \
           --set timer.preset2 "${preset2[@]}" \
           --add item timer.preset3 popup.timer \
           --set timer.preset3 "${preset3[@]}" \
           --add item timer.preset4 popup.timer \
           --set timer.preset4 "${preset4[@]}" \
           --add item timer.preset5 popup.timer \
           --set timer.preset5 "${preset5[@]}" \
           --add item timer.preset6 popup.timer \
           --set timer.preset6 "${preset6[@]}" \
           --add item timer.preset7 popup.timer \
           --set timer.preset7 "${preset7[@]}" \
           --add item timer.preset8 popup.timer \
           --set timer.preset8 "${preset8[@]}"