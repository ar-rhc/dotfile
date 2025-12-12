#!/bin/bash

# Get the current workspace ID from aerospace
CURRENT_WORKSPACE=$(aerospace current-workspace)

# Update sketchybar item appearance based on which workspace is active
for i in {1..9}; do
  if [ "$i" = "$CURRENT_WORKSPACE" ]; then
    # Active workspace
    sketchybar --set aerospace.workspace.$i background.color=0xffff6d00 \
                                         background.drawing=on \
                                         icon.color=0xff000000
  else
    # Inactive workspace
    sketchybar --set aerospace.workspace.$i background.color=0x40ffffff \
                                         background.drawing=on \
                                         icon.color=0xffffffff
  fi
done