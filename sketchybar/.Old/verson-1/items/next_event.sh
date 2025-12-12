#!/bin/bash

sketchybar --add item next_event right \
           --set next_event icon="" \
                            display=2\
                            update_freq=60 \
                            script="$PLUGIN_DIR/next_event.sh"

