#!/bin/bash

if [ "$SENDER" = "mouse.entered" ]; then
  osascript -e 'tell application "BetterTouchTool" to trigger_action "{BTTIsPureAction: 1, BTTPredefinedActionType: 125, BTTPredefinedActionName: \"Show Menu Bar in Context Menu\"}"'
fi
