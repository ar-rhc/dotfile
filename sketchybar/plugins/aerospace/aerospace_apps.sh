#!/bin/bash

# Get list of apps and save to temp file
TMP_FILE=$(mktemp /tmp/aerospace_apps.XXXXXX)
aerospace list-apps 2>/dev/null > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
  echo "No apps found" > "$TMP_FILE"
fi

# Open a new terminal window with the output
osascript <<EOF
tell application "Terminal"
  activate
  set newTab to do script "cat '$TMP_FILE' | head -100; echo ''; echo 'Press any key to close...'; read -n 1; rm -f '$TMP_FILE'; exit"
  set custom title of newTab to "AeroSpace Apps"
end tell
EOF
