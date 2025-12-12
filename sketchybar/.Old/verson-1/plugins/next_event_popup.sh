#!/bin/bash

# -----------------------------------------------------------------------------
# 1. CONFIGURATION
# -----------------------------------------------------------------------------
source "$CONFIG_DIR/colors.sh"

export TZ="Pacific/Auckland"
TEST_CALENDAR=""
POPUP_WIDTH=330

# Ensure main widget stays visible
sketchybar --set next_event drawing=on 2>/dev/null || true

# Colors
COLOR_HEADER=0xffa6da95  # Green for day headers
COLOR_TIME=0xff8aadf4    # Blue for time
COLOR_TEXT=0xffcad3f5    # White for text
BG_COLOR=0x20000000     # Dark Translucent

# -----------------------------------------------------------------------------
# 2. CLEAR & PREPARE
# -----------------------------------------------------------------------------
# Only remove popup items, not the main widget
sketchybar --remove '/next_event\.(header|event|empty)\.*/' 2>/dev/null || true

# Temporary file for sorting
TMP_FILE="/tmp/sketchybar_next_event_sort.txt"
: > "$TMP_FILE"

# -----------------------------------------------------------------------------
# 3. READ EVENTS FROM CACHE
# -----------------------------------------------------------------------------
CACHE_FILE="$CONFIG_DIR/.next_event_cache.txt"

# Read from cache file
if [ -f "$CACHE_FILE" ] && [ -s "$CACHE_FILE" ]; then
  EVENTS=$(cat "$CACHE_FILE")
else
  # Fallback: fetch if cache doesn't exist
  CMD="icalBuddy -n -nc -iep \"datetime,title\" -po \"datetime,title\" -ps \"|^|\" -tf \"%H:%M\" -df \"%Y-%m-%d\" -nrd -b \"\" -ea"
  if [ -n "$TEST_CALENDAR" ]; then
    EVENTS=$(eval $CMD -ic \"$TEST_CALENDAR\" eventsToday+5 2>&1)
  else
    EVENTS=$(eval $CMD eventsToday+5 2>&1)
  fi
fi

# Check for errors
if echo "$EVENTS" | grep -q "error:"; then
  if ! sketchybar --query "next_event.empty" &>/dev/null; then
    sketchybar --add item next_event.empty popup.next_event \
               --set next_event.empty label="No calendar access" \
                     background.drawing=off
  else
    sketchybar --set next_event.empty label="No calendar access" drawing=on
  fi
  exit 0
fi

if [ -z "$EVENTS" ] || [ "$EVENTS" = "" ]; then
  if ! sketchybar --query "next_event.empty" &>/dev/null; then
    sketchybar --add item next_event.empty popup.next_event \
               --set next_event.empty label="No events in next 3 days" \
                     background.drawing=off
  else
    sketchybar --set next_event.empty label="No events in next 3 days" drawing=on
  fi
  exit 0
fi

# -----------------------------------------------------------------------------
# 4. PARSE & SORT EVENTS
# -----------------------------------------------------------------------------
NOW_SEC=$(date +%s)

IFS=$'\n'
for line in $EVENTS; do
  if [ -z "$line" ] || [ "$line" = "" ]; then
    continue
  fi

  # Parse format: "2025-12-04 at 14:15 - 15:30|^|Event Title"
  if echo "$line" | grep -q "|^|"; then
    DATETIME_PART=$(echo "$line" | awk -F "\\|\\^\\|" '{print $1}')
    TITLE=$(echo "$line" | awk -F "\\|\\^\\|" '{print $2}' | xargs)
  else
    DATETIME_PART=$(echo "$line" | awk -F "^" '{print $1}')
    TITLE=$(echo "$line" | awk -F "^" '{print $2}' | xargs)
  fi

  # Skip if doesn't look like a date
  if [ -z "$DATETIME_PART" ] || ! echo "$DATETIME_PART" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}"; then
    continue
  fi

  if [ -z "$TITLE" ] || [ "$TITLE" = "" ]; then
    continue
  fi

  # Extract date and time
  TIME_PART=$(echo "$DATETIME_PART" | sed 's/.*at //')
  DATE_PART=$(echo "$DATETIME_PART" | awk '{print $1}')
  START_TIME=$(echo "$TIME_PART" | awk -F " - " '{print $1}')
  END_TIME=$(echo "$TIME_PART" | awk -F " - " '{print $2}')

  # Build start string for timestamp
  START_STR="$DATE_PART $START_TIME"
  START_SEC=$(date -j -f "%Y-%m-%d %H:%M" "$START_STR" +%s 2>/dev/null)

  if [ -z "$START_SEC" ]; then
    continue
  fi

  # Format time display
  if [ -n "$END_TIME" ]; then
    TIME_DISPLAY="$START_TIME - $END_TIME"
  else
    TIME_DISPLAY="$START_TIME"
  fi

  # Write to temp file for sorting: TIMESTAMP|DATE|TIME|TITLE
  echo "${START_SEC}|${DATE_PART}|${TIME_DISPLAY}|${TITLE}" >> "$TMP_FILE"
done
unset IFS

# -----------------------------------------------------------------------------
# 5. BUILD THE POPUP (Read Sorted Data)
# -----------------------------------------------------------------------------
COUNTER=0
LAST_DAY=""
HAS_EVENTS=0

# Sort by Timestamp (numerically) - use process substitution to avoid subshell
if [ -s "$TMP_FILE" ]; then
  while IFS="|" read -r TIMESTAMP DATE TIME_DISPLAY TITLE; do

    # A. DATE HEADERS (Dividers)
    # Convert timestamp to "Day, Month Date" format
    THIS_DAY=$(date -r "$TIMESTAMP" "+%A, %b %d" 2>/dev/null || echo "")

    if [ -z "$THIS_DAY" ]; then
      continue
    fi

    if [ "$THIS_DAY" != "$LAST_DAY" ]; then
      COUNTER=$((COUNTER + 1))
      sketchybar --add item next_event.header.$COUNTER popup.next_event \
                 --set next_event.header.$COUNTER \
                       label="$THIS_DAY" \
                       label.font="Hack Nerd Font:Bold:11.0" \
                       label.color=$COLOR_HEADER \
                       label.padding_left=8 \
                       label.padding_right=0 \
                       label.padding_top=0 \
                       label.padding_bottom=0 \
                       background.height=18 \
                       background.drawing=off \
                       width=$POPUP_WIDTH \
                       click_script="sketchybar --set next_event popup.drawing=off" 2>/dev/null || true
      LAST_DAY="$THIS_DAY"
    fi

    # B. COLOR LOGIC (Map Calendar Names to Colors)
    # You can customize this based on your calendar names
    case "$TITLE" in
      *"F1"*)          BAR_COLOR=0xffed8796 ;; # Red
      *"Tides"*)       BAR_COLOR=0xff939ab7 ;; # Grey
      *"Work"*)        BAR_COLOR=0xfff5a97f ;; # Orange
      *"Personal"*)    BAR_COLOR=0xff8aadf4 ;; # Blue
      *"Alex"*)        BAR_COLOR=0xffc6a0f6 ;; # Purple
      *"Swim"*)        BAR_COLOR=0xffa6da95 ;; # Green
      *"Reformer"*)    BAR_COLOR=0xffc6a0f6 ;; # Purple
      *)               BAR_COLOR=0xffcad3f5 ;; # Default White
    esac

    # C. ADD EVENT ROW
    COUNTER=$((COUNTER + 1))
    HAS_EVENTS=1

    # Truncate Title if too long
    if [ ${#TITLE} -gt 30 ]; then
      TITLE="${TITLE:0:29}…"
    fi

    sketchybar --add item next_event.event.$COUNTER popup.next_event \
               --set next_event.event.$COUNTER \
                     icon="•" \
                     icon.font="Hack Nerd Font:Bold:11.0" \
                     icon.color=$BAR_COLOR \
                     icon.padding_left=8 \
                     icon.padding_right=4 \
                     label="$TIME_DISPLAY  $TITLE" \
                     label.font="Hack Nerd Font:Regular:10.5" \
                     label.color=$COLOR_TEXT \
                     label.padding_left=0 \
                     label.padding_right=8 \
                     label.padding_top=0 \
                     label.padding_bottom=0 \
                     background.height=18 \
                     background.color=$BG_COLOR \
                     background.corner_radius=2 \
                     background.drawing=on \
                     width=$POPUP_WIDTH \
                     click_script="sketchybar --set next_event popup.drawing=off" 2>/dev/null || true

  done < <(sort -n "$TMP_FILE")
fi

# Hide empty message if we have events
if [ $HAS_EVENTS -gt 0 ]; then
  if sketchybar --query "next_event.empty" &>/dev/null; then
    sketchybar --set next_event.empty drawing=off 2>/dev/null || true
  fi
fi

# Cleanup
rm "$TMP_FILE" 2>/dev/null
