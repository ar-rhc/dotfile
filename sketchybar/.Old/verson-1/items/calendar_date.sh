#!/bin/bash

sketchybar --add item calendar_date right \
           --set calendar_date icon=􀧞  \
                              update_freq=60 \
                              script="$PLUGIN_DIR/calendar_date.sh" \
                              #click_script="open -a Calendar"

