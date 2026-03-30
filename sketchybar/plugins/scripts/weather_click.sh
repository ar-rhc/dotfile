#!/bin/bash

# Weather widget click handler
# Left click: trigger BetterTouchTool action
# Right click: open Weather app

if [ "$BUTTON" = "right" ]; then
  # Right click: open Weather app
  open -a "Weather" 2>/dev/null || open -a "Weather.app" 2>/dev/null
elif [ "$BUTTON" = "left" ]; then
  # Left click: trigger BetterTouchTool action
  osascript -e 'tell application "BetterTouchTool" to trigger_named "metero"' 2>/dev/null
fi
