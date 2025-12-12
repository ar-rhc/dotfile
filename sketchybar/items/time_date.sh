#!/bin/bash

# Time item
sketchybar -m \
  --add item time right \
  --set time \
    update_freq=2 \
    icon.padding_right=0 \
    label.padding_left=0 \
    script="$PLUGIN_DIR/time.sh"






