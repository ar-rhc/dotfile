#!/bin/bash

# Get list of windows and save to temp file
TMP_FILE=$(mktemp /tmp/aerospace_windows.XXXXXX)
aerospace list-windows --all 2>/dev/null > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
  echo "No windows found" > "$TMP_FILE"
fi

# Open a new terminal window with the output
osascript <<EOF
tell application "Terminal"
  activate
  set newTab to do script "cat '$TMP_FILE' | head -100; echo ''; echo 'Press any key to close...'; read -n 1; rm -f '$TMP_FILE'; exit"
  set custom title of newTab to "AeroSpace Windows"
end tell
EOF
