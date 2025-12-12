#!/bin/bash

if [ "$NAME" = "calendar_date" ]; then
  sketchybar --set $NAME label="$(date +'%a %d %b')"
elif [ "$NAME" = "calendar_time" ]; then
  sketchybar --set $NAME label="$(date +'%I:%M %p')"
fi
