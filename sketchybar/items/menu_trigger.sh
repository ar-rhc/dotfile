#!/bin/bash

sketchybar --add item menu_trigger left \
  --set menu_trigger \
    icon=􀌜 \
    icon.font="$FONT:Regular:16.0" \
    label.drawing=off \
    click_script="osascript -e 'tell application \"BetterTouchTool\" to trigger_action \"{BTTIsPureAction: 1, BTTPredefinedActionType: 125, BTTPredefinedActionName: \\\"Show Menu Bar in Context Menu\\\"}\"'"
