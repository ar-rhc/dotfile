#!/bin/bash

sketchybar --add item calendar_date right \
           --set calendar_date icon=􀧞  \
                              update_freq=30 \
                              script="$PLUGIN_DIR/calendar_date.sh" \
                              #click_script="open -a Calendar" \
           --add item calendar_time right \
           --set calendar_time update_freq=10 \
                              script="$PLUGIN_DIR/calendar_time.sh" \
                              #click_script="open -a 'System Preferences' && open 'x-apple.systempreferences:com.apple.preference.datetime'"
