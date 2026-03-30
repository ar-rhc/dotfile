#!/bin/bash

# Trigger BTT action
# Replace "YourActionName" with the actual BTT action name or use BTT's trigger mechanism
# Option 1: Using BTT's command line tool (if available)
# btt-cli trigger "YourActionName"

# Option 2: Using AppleScript to trigger BTT action
# osascript -e 'tell application "BetterTouchTool" to trigger_action "YourActionName"'

# Option 3: Using BTT's URL scheme (most reliable)
# Replace "action_name" with your actual BTT action name
open "btt://execute_assigned_actions_for_trigger/?uuid=B341477C-E26B-4576-AC89-837BF6242A1E"

# If you need to use a different method, uncomment and modify one of the above options

