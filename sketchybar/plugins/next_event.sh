#!/bin/bash

# =============================================================================
# SKETCHYBAR CALENDAR WIDGET - Next Event Display
# =============================================================================
# Shows the next upcoming calendar event with time remaining
# =============================================================================

# -----------------------------------------------------------------------------
# CONFIGURATION
# -----------------------------------------------------------------------------
export TZ="Pacific/Auckland"

# Test mode - uncomment and set calendar name to test with specific calendar
# TEST_CALENDAR="Work"

# Calendars to exclude (comma-separated)
EXCLUDE_CALENDARS="Shorebird Centre Tides & Events"

# Display settings
MAX_TITLE_LENGTH=20
LOOKAHEAD_DAYS=1  # Days to look ahead for main widget

# Debug mode - set to true to enable debug output
DEBUG=false

# -----------------------------------------------------------------------------
# HELPER FUNCTIONS
# -----------------------------------------------------------------------------

debug() {
  if [ "$DEBUG" = true ]; then
    echo "[DEBUG] $*" >&2
  fi
}

# Format time remaining as human-readable string
format_time_remaining() {
  local seconds="$1"
  local prefix="$2"  # "in" for future, empty for ongoing
  
  local total_mins=$((seconds / 60))
  local hours=$((seconds / 3600))
  local mins=$(((seconds % 3600) / 60))
  
  if [ $total_mins -ge 60 ]; then
    if [ -n "$prefix" ]; then
      echo "•${prefix} ${hours}hr ${mins}min"
    else
      echo "•${hours}hr ${mins}min left"
    fi
  else
    if [ -n "$prefix" ]; then
      echo "•${prefix} ${mins}min"
    else
      echo "•${mins}min left"
    fi
  fi
}

# Truncate title if too long
truncate_title() {
  local title="$1"
  local max_length="${2:-$MAX_TITLE_LENGTH}"
  
  if [ ${#title} -gt $max_length ]; then
    echo "${title:0:$max_length}..."
  else
    echo "$title"
  fi
}

# Update SketchyBar widget
update_widget() {
  local label="$1"
  sketchybar --set "$NAME" label="$label" drawing=on
}

# -----------------------------------------------------------------------------
# CALENDAR EVENT FETCHING
# -----------------------------------------------------------------------------

build_icalbuddy_command() {
  local days="$1"
  
  # Build exclude flag
  local exclude_flag
  if [ -n "$EXCLUDE_CALENDARS" ]; then
    exclude_flag="-ec \"$EXCLUDE_CALENDARS\""
  else
    exclude_flag="-ec \"\""
  fi
  
  # Build calendar flag
  local calendar_flag=""
  if [ -n "$TEST_CALENDAR" ]; then
    calendar_flag="-ic \"$TEST_CALENDAR\""
  fi
  
  echo "icalBuddy -n -nc $exclude_flag $calendar_flag -iep \"datetime,title\" -po \"datetime,title\" -ps \"|^|\" -tf \"%H:%M\" -df \"%Y-%m-%d\" -nrd -b \"\" -ea eventsToday+${days}"
}

fetch_events() {
  local days="$1"
  local cmd=$(build_icalbuddy_command "$days")
  
  debug "Fetching events: $cmd"
  eval "$cmd" 2>&1
}

# -----------------------------------------------------------------------------
# EVENT PARSING
# -----------------------------------------------------------------------------

parse_event_line() {
  local line="$1"
  
  # Skip empty lines
  if [ -z "$line" ]; then
    return 1
  fi
  
  # Parse datetime and title
  local datetime_part title_part
  if echo "$line" | grep -q "|^|"; then
    datetime_part=$(echo "$line" | awk -F "\\|\\^\\|" '{print $1}')
    title_part=$(echo "$line" | awk -F "\\|\\^\\|" '{print $2}' | xargs)
  else
    datetime_part=$(echo "$line" | awk -F "^" '{print $1}')
    title_part=$(echo "$line" | awk -F "^" '{print $2}' | xargs)
  fi
  
  # Validate datetime format
  if [ -z "$datetime_part" ] || ! echo "$datetime_part" | grep -qE "^[0-9]{4}-[0-9]{2}-[0-9]{2}"; then
    return 1
  fi
  
  # Validate title
  if [ -z "$title_part" ]; then
    return 1
  fi
  
  # Extract date and time components
  local date_part=$(echo "$datetime_part" | awk '{print $1}')
  local time_part=$(echo "$datetime_part" | sed 's/.*at //')
  local start_time=$(echo "$time_part" | awk -F " - " '{print $1}')
  local end_time=$(echo "$time_part" | awk -F " - " '{print $2}')
  
  # Parse start timestamp
  local start_str="$date_part $start_time"
  local start_sec=$(date -j -f "%Y-%m-%d %H:%M" "$start_str" +%s 2>/dev/null)
  
  if [ -z "$start_sec" ]; then
    return 1
  fi
  
  # Parse end timestamp (default to 1 hour if not specified)
  local end_sec
  if [ -n "$end_time" ]; then
    local end_str="$date_part $end_time"
    end_sec=$(date -j -f "%Y-%m-%d %H:%M" "$end_str" +%s 2>/dev/null)
  else
    end_sec=$((start_sec + 3600))
  fi
  
  # Output parsed event (format: title|start_sec|end_sec)
  echo "${title_part}|${start_sec}|${end_sec}"
  return 0
}

# -----------------------------------------------------------------------------
# EVENT SELECTION LOGIC
# -----------------------------------------------------------------------------

find_best_event() {
  local events="$1"
  local now_sec=$(date +%s)
  
  local current_event="" current_start=0 current_end=0
  local next_event="" next_start=0 next_end=0
  
  # Parse all events
  IFS=$'\n'
  for line in $events; do
    local parsed=$(parse_event_line "$line")
    
    if [ $? -ne 0 ] || [ -z "$parsed" ]; then
      continue
    fi
    
    # Extract parsed components
    local title=$(echo "$parsed" | cut -d'|' -f1)
    local start_sec=$(echo "$parsed" | cut -d'|' -f2)
    local end_sec=$(echo "$parsed" | cut -d'|' -f3)
    
    # Check if this is the current event (ongoing)
    if [ $start_sec -le $now_sec ] && [ $end_sec -gt $now_sec ]; then
      current_event="$title"
      current_start=$start_sec
      current_end=$end_sec
      debug "Found current event: $title"
    fi
    
    # Check if this is the next upcoming event
    if [ $start_sec -gt $now_sec ]; then
      if [ $next_start -eq 0 ] || [ $start_sec -lt $next_start ]; then
        next_event="$title"
        next_start=$start_sec
        next_end=$end_sec
        debug "Found next event: $title"
      fi
    fi
  done
  unset IFS
  
  # Output best event (format: type|title|start|end)
  # Type: "current" or "next"
  
  # Priority 1: If next event starts before current ends, show next event
  if [ -n "$current_event" ] && [ $current_end -gt 0 ] && \
     [ -n "$next_event" ] && [ $next_start -gt 0 ] && \
     [ $next_start -lt $current_end ]; then
    echo "next|$next_event|$next_start|$next_end"
    return 0
  fi
  
  # Priority 2: Show current event if exists
  if [ -n "$current_event" ] && [ $current_end -gt 0 ]; then
    echo "current|$current_event|$current_start|$current_end"
    return 0
  fi
  
  # Priority 3: Show next upcoming event
  if [ -n "$next_event" ] && [ $next_start -gt 0 ]; then
    echo "next|$next_event|$next_start|$next_end"
    return 0
  fi
  
  # No valid events found
  return 1
}

# -----------------------------------------------------------------------------
# DISPLAY LOGIC
# -----------------------------------------------------------------------------

display_event() {
  local event_type="$1"    # "current" or "next"
  local title="$2"
  local start_sec="$3"
  local end_sec="$4"
  
  local now_sec=$(date +%s)
  
  if [ "$event_type" = "current" ]; then
    # Display ongoing event
    local time_left=$((end_sec - now_sec))
    
    if [ $time_left -le 0 ]; then
      # Event just ended
      update_widget "$(truncate_title "$title") •ending"
    else
      local time_str=$(format_time_remaining "$time_left" "")
      update_widget "$(truncate_title "$title") $time_str"
    fi
    
  elif [ "$event_type" = "next" ]; then
    # Display upcoming event
    local time_until=$((start_sec - now_sec))
    
    if [ $time_until -le 0 ]; then
      # Event is starting now (shouldn't happen, but handle gracefully)
      update_widget "$(truncate_title "$title") •starting"
    else
      local time_str=$(format_time_remaining "$time_until" "in")
      update_widget "$(truncate_title "$title") $time_str"
    fi
  fi
}

# -----------------------------------------------------------------------------
# MAIN EXECUTION
# -----------------------------------------------------------------------------

main() {
  # Fetch events for main widget
  debug "Fetching events for $LOOKAHEAD_DAYS days"
  local events=$(fetch_events "$LOOKAHEAD_DAYS")
  
  # Check for icalBuddy errors
  if echo "$events" | grep -q "error:"; then
    if echo "$events" | grep -q "error: No calendars"; then
      update_widget "No calendar access"
    else
      update_widget "Calendar error"
    fi
    exit 0
  fi
  
  # Check if events are empty
  if [ -z "$events" ]; then
    update_widget "No events"
    exit 0
  fi
  
  # Find the best event to display
  local best_event=$(find_best_event "$events")
  
  if [ $? -ne 0 ] || [ -z "$best_event" ]; then
    update_widget "No upcoming events"
    exit 0
  fi
  
  # Parse and display the best event
  local event_type=$(echo "$best_event" | cut -d'|' -f1)
  local title=$(echo "$best_event" | cut -d'|' -f2)
  local start_sec=$(echo "$best_event" | cut -d'|' -f3)
  local end_sec=$(echo "$best_event" | cut -d'|' -f4)
  
  debug "Displaying $event_type event: $title"
  display_event "$event_type" "$title" "$start_sec" "$end_sec"
}

# Run main function
main "$@"
