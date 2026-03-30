#!/bin/sh

# Hide on desktop Macs (no battery = not a laptop)
if ! pmset -g batt 2>/dev/null | grep -q "Battery"; then
  sketchybar --set wifi drawing=off
  exit 0
fi

SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | awk -F:  '($1 ~ "^ *SSID$"){print $2}' | cut -c 2-)

if [ -z "$SSID" ]; then
  sketchybar --set wifi icon=󰖪 icon.color=0xff58d1fc label="No WiFi"
else
  sketchybar --set wifi icon=󰖩 icon.color=0xff58d1fc label="$SSID"
fi
