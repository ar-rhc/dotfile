#!/bin/bash

# Play/pause on click, open Music app on cmd+click

if [ "$BUTTON" = "left" ] && [ "$MODIFIER" = "alt" ]; then
  osascript -e 'tell application "Music" to next track'
elif [ "$BUTTON" = "left" ] && [ "$MODIFIER" = "ctrl" ]; then
  osascript -e 'tell application "Music" to previous track'
elif [ "$BUTTON" = "left" ] && [ "$MODIFIER" = "cmd" ]; then
  open -a "Music"
elif [ "$BUTTON" = "left" ]; then
  osascript -e 'tell application "Music" to playpause'
elif [ "$BUTTON" = "right" ]; then
  sketchybar --set music popup.drawing=toggle
fi
