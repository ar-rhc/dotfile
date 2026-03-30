#!/bin/bash

# Get calendar icon for day of month (1-31)
# SF Symbols calendar badge icons (calendar.badge.1 through calendar.badge.31)
get_calendar_icon() {
  local day=$(date +%d | sed 's/^0//')  # Remove leading zero, get day 1-31
  
  case "$day" in
    1) echo "􃌦" ;;   # calendar.badge.1
    2) echo "􃌧" ;;   # calendar.badge.2
    3) echo "􃌨" ;;   # calendar.badge.3
    4) echo "􃌩" ;;   # calendar.badge.4
    5) echo "􃌪" ;;   # calendar.badge.5
    6) echo "􃌫" ;;   # calendar.badge.6
    7) echo "􃌬" ;;   # calendar.badge.7
    8) echo "􃌭" ;;   # calendar.badge.8
    9) echo "􃌮" ;;   # calendar.badge.9
    10) echo "􃌯" ;;  # calendar.badge.10
    11) echo "􃌰" ;;  # calendar.badge.11
    12) echo "􃌱" ;;  # calendar.badge.12
    13) echo "􃌲" ;;  # calendar.badge.13
    14) echo "􃌳" ;;  # calendar.badge.14
    15) echo "􃌴" ;;  # calendar.badge.15
    16) echo "􃌵" ;;  # calendar.badge.16
    17) echo "􃌶" ;;  # calendar.badge.17
    18) echo "􃌷" ;;  # calendar.badge.18
    19) echo "􃌸" ;;  # calendar.badge.19
    20) echo "􃌹" ;;  # calendar.badge.20
    21) echo "􃌺" ;;  # calendar.badge.21
    22) echo "􃌻" ;;  # calendar.badge.22
    23) echo "􃌼" ;;  # calendar.badge.23
    24) echo "􃌽" ;;  # calendar.badge.24
    25) echo "􃌾" ;;  # calendar.badge.25
    26) echo "􃌿" ;;  # calendar.badge.26
    27) echo "􃍀" ;;  # calendar.badge.27
    28) echo "􃍁" ;;  # calendar.badge.28
    29) echo "􃍂" ;;  # calendar.badge.29
    30) echo "􃍃" ;;  # calendar.badge.30
    31) echo "􃍄" ;;  # calendar.badge.31
    *) echo "􀉉" ;;  # calendar (default/base)
  esac
}

# Update calendar widget with dynamic icon based on day
CALENDAR_ICON=$(get_calendar_icon)
sketchybar --set "$NAME" icon="$CALENDAR_ICON" label="$(date '+%a %d %b - %H:%M')"
