#!/bin/bash

CONFIG="$HOME/dotfiles/aerospace/aerospace.toml"

# Check current inner gap value
CURRENT=$(grep 'inner.horizontal' "$CONFIG" | head -1 | grep -o '[0-9]*')

if [ "$CURRENT" -gt 0 ] 2>/dev/null; then
  # Set gaps to 0
  sed -i '' 's/inner.horizontal = [0-9]*/inner.horizontal = 0/' "$CONFIG"
  sed -i '' 's/inner.vertical = [0-9]*/inner.vertical = 0/' "$CONFIG"
  sed -i '' 's/outer.left = [0-9]*/outer.left = 0/' "$CONFIG"
  sed -i '' 's/outer.bottom = [0-9]*/outer.bottom = 0/' "$CONFIG"
  sed -i '' 's/outer.right = [0-9]*/outer.right = 0/' "$CONFIG"
else
  # Restore gaps
  sed -i '' 's/inner.horizontal = [0-9]*/inner.horizontal = 5/' "$CONFIG"
  sed -i '' 's/inner.vertical = [0-9]*/inner.vertical = 5/' "$CONFIG"
  sed -i '' 's/outer.left = [0-9]*/outer.left = 5/' "$CONFIG"
  sed -i '' 's/outer.bottom = [0-9]*/outer.bottom = 5/' "$CONFIG"
  sed -i '' 's/outer.right = [0-9]*/outer.right = 5/' "$CONFIG"
fi

aerospace reload-config 2>/dev/null
