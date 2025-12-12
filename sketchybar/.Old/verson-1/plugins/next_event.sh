#!/bin/bash

# -----------------------------------------------------------------------------
# 1. SETTINGS & TIMEZONE
# -----------------------------------------------------------------------------
export TZ="Pacific/Auckland"
TEST_CALENDAR="" 

# -----------------------------------------------------------------------------
# 2. FETCH ALL EVENTS (48 HOUR WINDOW)
# -----------------------------------------------------------------------------
CMD="icalBuddy -n -nc -iep \"datetime,title\" -po \"datetime,title\" -ps \"|^|\" -tf \"%H:%M\" -df \"%Y-%m-%d\" -nrd -b \"\" -ea"

# Cache file for popup (3 days of events)
CACHE_FILE="$CONFIG_DIR/.next_event_cache.txt"

# Fetch events for main widget (1 day)
if [ -n "$TEST_CALENDAR" ]; then
  EVENTS=$(eval $CMD -ic \"$TEST_CALENDAR\" eventsToday+1 2>&1)
else
  EVENTS=$(eval $CMD eventsToday+1 2>&1)
fi

# Also fetch and cache 3 days of events for popup
if [ -n "$TEST_CALENDAR" ]; then
  CACHE_EVENTS=$(eval $CMD -ic \"$TEST_CALENDAR\" eventsToday+3 2>&1)
else
  CACHE_EVENTS=$(eval $CMD eventsToday+3 2>&1)
fi

# Save to cache file if successful
if ! echo "$CACHE_EVENTS" | grep -q "error:"; then
  echo "$CACHE_EVENTS" > "$CACHE_FILE" 2>/dev/null || true
fi

# Check for icalBuddy errors
if echo "$EVENTS" | grep -q "error:"; then
  if echo "$EVENTS" | grep -q "error: No calendars"; then
    sketchybar --set $NAME label="No calendar access" drawing=on
  else
    sketchybar --set $NAME label="Calendar error" drawing=on
  fi
  exit 0
fi

if [ -z "$EVENTS" ] || [ "$EVENTS" = "" ]; then
  sketchybar --set $NAME label="No events" drawing=on
  exit 0
fi

# -----------------------------------------------------------------------------
# 3. PARSE ALL EVENTS AND FIND THE RIGHT ONE
# -----------------------------------------------------------------------------
NOW_SEC=$(date +%s)
CURRENT_EVENT=""
NEXT_EVENT=""
CURRENT_EVENT_END=0
NEXT_EVENT_START=0
NEXT_EVENT_END=0
EVENT_COUNT=0

# Process all events
IFS=$'\n'
for line in $EVENTS; do
  if [ -z "$line" ] || [ "$line" = "" ]; then
    continue
  fi
  
  EVENT_COUNT=$((EVENT_COUNT + 1))

  if echo "$line" | grep -q "|^|"; then
    DATETIME_PART=$(echo "$line" | awk -F "\\|\\^\\|" '{print $1}')
    TITLE_PART=$(echo "$line" | awk -F "\\|\\^\\|" '{print $2}' | xargs)
  else
    DATETIME_PART=$(echo "$line" | awk -F "^" '{print $1}')
    TITLE_PART=$(echo "$line" | awk -F "^" '{print $2}' | xargs)
  fi

  if [ -z "$DATETIME_PART" ] || ! echo "$DATETIME_PART" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}"; then
    continue
  fi
  
  if [ -z "$TITLE_PART" ] || [ "$TITLE_PART" = "" ]; then
    continue
  fi

  TIME_PART=$(echo "$DATETIME_PART" | sed 's/.*at //')
  DATE_PART=$(echo "$DATETIME_PART" | awk '{print $1}')
  START_TIME=$(echo "$TIME_PART" | awk -F " - " '{print $1}')
  END_TIME=$(echo "$TIME_PART" | awk -F " - " '{print $2}')

  START_STR="$DATE_PART $START_TIME"
  START_SEC=$(date -j -f "%Y-%m-%d %H:%M" "$START_STR" +%s 2>/dev/null)
  
  if [ -z "$START_SEC" ]; then
    continue
  fi

  if [ -n "$END_TIME" ]; then
    END_STR="$DATE_PART $END_TIME"
    END_SEC=$(date -j -f "%Y-%m-%d %H:%M" "$END_STR" +%s 2>/dev/null)
  else
    END_SEC=$((START_SEC + 3600))
  fi

  # Check if this is the current event
  if [ $START_SEC -le $NOW_SEC ] && [ $END_SEC -gt $NOW_SEC ]; then
    CURRENT_EVENT="$TITLE_PART"
    CURRENT_EVENT_END=$END_SEC
  fi

  # Check if this is the next upcoming event
  if [ $START_SEC -gt $NOW_SEC ]; then
    if [ $NEXT_EVENT_START -eq 0 ] || [ $START_SEC -lt $NEXT_EVENT_START ]; then
      NEXT_EVENT="$TITLE_PART"
      NEXT_EVENT_START=$START_SEC
      NEXT_EVENT_END=$END_SEC
    fi
  fi
done
unset IFS

# -----------------------------------------------------------------------------
# 4. PRIORITY LOGIC
# -----------------------------------------------------------------------------

# Priority 1: Next event starts before current event ends
if [ -n "$CURRENT_EVENT" ] && [ $CURRENT_EVENT_END -gt 0 ] && [ -n "$NEXT_EVENT" ] && [ $NEXT_EVENT_START -gt 0 ]; then
  if [ $NEXT_EVENT_START -lt $CURRENT_EVENT_END ]; then
    # Next event starts before current ends - show next event
    DIFF_START=$((NEXT_EVENT_START - NOW_SEC))
    DIFF_END=$((NEXT_EVENT_END - NOW_SEC))
    
    # If next event is ongoing
    if [ $DIFF_START -le 0 ] && [ $DIFF_END -gt 0 ]; then
      TOTAL_MINS=$((DIFF_END / 60))
      HRS=$((DIFF_END / 3600))
      MINS=$(( (DIFF_END % 3600) / 60 ))
      
      if [ $TOTAL_MINS -ge 60 ]; then
        TIME_STR="•${HRS}hr ${MINS}min left"
      else
        TIME_STR="•${MINS}min left"
      fi
      
      sketchybar --set $NAME label="$NEXT_EVENT $TIME_STR" drawing=on
      exit 0
    fi
    
    # If next event is upcoming
    if [ $DIFF_START -gt 0 ]; then
      TOTAL_MINS=$((DIFF_START / 60))
      HRS=$((DIFF_START / 3600))
      MINS=$(( (DIFF_START % 3600) / 60 ))
      
      if [ $TOTAL_MINS -ge 60 ]; then
        TIME_STR="•in ${HRS}hr ${MINS}min"
      else
        TIME_STR="•${MINS}min left"
      fi
      
      if [ ${#NEXT_EVENT} -gt 20 ]; then
        NEXT_EVENT="${NEXT_EVENT:0:20}..."
      fi
      
      sketchybar --set $NAME label="$NEXT_EVENT $TIME_STR" drawing=on
      exit 0
    fi
  fi
fi

# Priority 2: Current event fallback
if [ -n "$CURRENT_EVENT" ] && [ $CURRENT_EVENT_END -gt 0 ]; then
  if [ -z "$NEXT_EVENT" ] || [ $NEXT_EVENT_END -lt $NOW_SEC ] || [ $NEXT_EVENT_START -ge $CURRENT_EVENT_END ]; then
    DIFF_END=$((CURRENT_EVENT_END - NOW_SEC))
    
    if [ $DIFF_END -gt 0 ]; then
      TOTAL_MINS=$((DIFF_END / 60))
      HRS=$((DIFF_END / 3600))
      MINS=$(( (DIFF_END % 3600) / 60 ))
      
      # --- FIX WAS APPLIED HERE ---
      if [ $TOTAL_MINS -ge 60 ]; then
        TIME_STR="•${HRS}hr ${MINS}min left"
      else
        TIME_STR="•${MINS}min left"
      fi
      
      sketchybar --set $NAME label="$CURRENT_EVENT $TIME_STR" drawing=on
      exit 0
    fi
  fi
fi

# Priority 0: Simple case - just show next upcoming event
if [ -n "$NEXT_EVENT" ] && [ $NEXT_EVENT_START -gt 0 ]; then
  DIFF_START=$((NEXT_EVENT_START - NOW_SEC))
  
  TOTAL_MINS=$((DIFF_START / 60))
  HRS=$((DIFF_START / 3600))
  MINS=$(( (DIFF_START % 3600) / 60 ))
  
  if [ $TOTAL_MINS -ge 60 ]; then
    TIME_STR="•${HRS}hr ${MINS}min left"
  else
    TIME_STR="•${MINS}min left"
  fi
  
  if [ ${#NEXT_EVENT} -gt 20 ]; then
    NEXT_EVENT="${NEXT_EVENT:0:20}..."
  fi
  
  sketchybar --set $NAME label="$NEXT_EVENT $TIME_STR" drawing=on
  exit 0
fi

# No events found
if [ $EVENT_COUNT -eq 0 ]; then
  sketchybar --set $NAME label="No events found" drawing=on
else
  sketchybar --set $NAME label="No valid events" drawing=on
fi