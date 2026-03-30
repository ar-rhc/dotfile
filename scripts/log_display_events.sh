#!/usr/bin/env bash
# Log display/sleep/wake/backlight events to find what triggers HP monitor dimming.
# Run: ./log_display_events.sh
# When the HP goes dim, check: tail -100 ~/display_events.log

LOG="$HOME/display_events.log"
echo "=== Started $(date) ===" >> "$LOG"

/usr/bin/log stream --predicate 'eventMessage contains "display" OR eventMessage contains "Display" OR eventMessage contains "sleep" OR eventMessage contains "Wake" OR eventMessage contains "Backlight" OR eventMessage contains "backlight" OR process == "powerd" OR process == "WindowServer"' --style compact 2>&1 | while read -r line; do
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $line" >> "$LOG"
done
