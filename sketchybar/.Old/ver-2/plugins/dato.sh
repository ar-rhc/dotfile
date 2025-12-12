#!/bin/bash

# Dato integration with clean 12-hour format
# Simple, clean date and time display

# Get current date and time in 12-hour format  
DATE=$(date '+%a %b %-d')
TIME=$(date '+%-I:%M %p')

# Set clean label without duplicate day number
sketchybar --set "$NAME" label="$DATE  $TIME"
