#!/bin/bash

sketchybar --add item calendar_time right \
           --set calendar_time update_freq=10 \
                              label.padding_left=-5 \
                              script="$PLUGIN_DIR/calendar_time.sh" \
                              #click_script="open -a 'System Preferences' && open 'x-apple.systempreferences:com.apple.preference.datetime'"

