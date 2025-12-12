#!/bin/bash

# Minimal click handler for the calendar widget
# Edit these to your BetterTouchTool trigger IDs
BTT_TRIGGER_CLICK="7C339A79-000D-475F-BDE6-4F38094C9367"           # plain click
BTT_TRIGGER_SHIFT_CLICK="C6F1ADBE-9DC6-40BD-A5A2-BA4EE5DF0FAD"            # shift + click

# SketchyBar provides $BUTTON (left/right/other) and $MODIFIER (shift/ctrl/alt/cmd)
# We only care about left click and shift + left click.

if [ "$BUTTON" = "right" ]; then
  osascript -e "tell application \"BetterTouchTool\" to execute_assigned_actions_for_trigger \"$BTT_TRIGGER_SHIFT_CLICK\"" 2>/dev/null
elif [ "$BUTTON" = "left" ] && [ "$MODIFIER" = "cmd" ]; then
  open -a "Calendar"
elif [ "$BUTTON" = "left" ]; then
  osascript -e "tell application \"BetterTouchTool\" to execute_assigned_actions_for_trigger \"$BTT_TRIGGER_CLICK\"" 2>/dev/null
fi
