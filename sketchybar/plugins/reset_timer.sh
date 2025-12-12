#!/usr/bin/env bash

# Kill any running timer.py processes
pgrep -f "$PLUGIN_DIR/timer.py" >/dev/null 2>&1 && pgrep -f "$PLUGIN_DIR/timer.py" | xargs -r kill

# Clear timer label
sketchybar --set timer label=""





