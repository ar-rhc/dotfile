#!/bin/bash
/opt/homebrew/bin/brew outdated 2>/dev/null | wc -l | tr -d ' ' > /tmp/sketchybar_brew_count
