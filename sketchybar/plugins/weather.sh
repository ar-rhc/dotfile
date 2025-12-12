#!/usr/bin/env bash

# Configuration
LOCATION="Auckland"
REGION="NZ"
LANG="en"
CACHE_FILE="/tmp/sketchybar_weather_cache.json"
CACHE_DURATION=600  # Cache for 10 minutes (600 seconds)

# Properly escape spaces and construct the URL
LOCATION_ESCAPED="$(echo "$LOCATION" | sed 's/ /+/g')+$(echo "$REGION" | sed 's/ /+/g')"

# Check if cache exists and is still valid
USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)))
  if [ "$CACHE_AGE" -lt "$CACHE_DURATION" ]; then
    USE_CACHE=true
  fi
fi

# Fetch weather data (from cache or API)
if [ "$USE_CACHE" = true ]; then
  # Use cached data
  WEATHER_JSON=$(cat "$CACHE_FILE")
  # Update in background for next time
  (curl -fsSL --max-time 5 "https://wttr.in/${LOCATION_ESCAPED}?0pq&format=j1&lang=${LANG}" > "$CACHE_FILE" 2>/dev/null &)
else
  # Show loading only if we don't have cache
  if [ ! -f "$CACHE_FILE" ]; then
    sketchybar --set "$NAME" \
      label="Loading..." \
      icon.color=0xff5edaff
  fi
  
  # Fetch new data
  WEATHER_JSON=$(curl -fsSL --max-time 5 "https://wttr.in/${LOCATION_ESCAPED}?0pq&format=j1&lang=${LANG}")
  
  # Save to cache if valid
  if [ -n "$WEATHER_JSON" ] && echo "$WEATHER_JSON" | jq . >/dev/null 2>&1; then
    echo "$WEATHER_JSON" > "$CACHE_FILE"
  fi
fi

# Fallback if curl or jq failed, or WEATHER_JSON is empty/invalid
if [ -z "$WEATHER_JSON" ] || ! echo "$WEATHER_JSON" | jq . >/dev/null 2>&1; then
  # Try to use cache even if expired
  if [ -f "$CACHE_FILE" ]; then
    WEATHER_JSON=$(cat "$CACHE_FILE")
    if [ -z "$WEATHER_JSON" ] || ! echo "$WEATHER_JSON" | jq . >/dev/null 2>&1; then
      sketchybar --set "$NAME" \
        label="$LOCATION" \
        icon=􀇬 \
        icon.color=0xff5edaff
      exit 0
    fi
  else
    sketchybar --set "$NAME" \
      label="$LOCATION" \
      icon=􀇬 \
      icon.color=0xff5edaff
  exit 0
fi
fi

TEMPERATURE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C // ""')
WEATHER_DESCRIPTION_RAW=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value // ""')
WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode // ""')
WIND_DIRECTION=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].winddir16Point // ""')
WIND_SPEED_KMPH=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].windspeedKmph // ""')

# Truncate description if too long (only if it exists)
if [ -n "$WEATHER_DESCRIPTION_RAW" ] && [ "$WEATHER_DESCRIPTION_RAW" != "null" ]; then
  if [ ${#WEATHER_DESCRIPTION_RAW} -gt 12 ]; then
    WEATHER_DESCRIPTION="${WEATHER_DESCRIPTION_RAW:0:12}..."
  else
    WEATHER_DESCRIPTION="$WEATHER_DESCRIPTION_RAW"
  fi
else
  WEATHER_DESCRIPTION=""
fi

# Format wind info
WIND_INFO=""
if [ -n "$WIND_DIRECTION" ] && [ "$WIND_DIRECTION" != "null" ] && [ -n "$WIND_SPEED_KMPH" ] && [ "$WIND_SPEED_KMPH" != "null" ]; then
  WIND_INFO=" • ${WIND_DIRECTION} ${WIND_SPEED_KMPH}km/h"
fi

# If temperature or description are empty/null, fallback to generic label
if [ -z "$TEMPERATURE" ] || [ "$TEMPERATURE" == "null" ] || [ -z "$WEATHER_DESCRIPTION" ] || [ "$WEATHER_DESCRIPTION" == "null" ]; then
  sketchybar --set "$NAME" \
    label="$LOCATION" \
    icon=􀇬 \
    icon.color=0xff5edaff
  exit 0
fi

# Map weather conditions to icons
# Weather codes: https://www.worldweatheronline.com/weather-api/api/docs/weather-icons.aspx
get_weather_icon() {
  local code=$1
  local desc=$(echo "$2" | tr '[:upper:]' '[:lower:]')
  
  # Clear/Sunny
  if [[ "$code" == "113" ]] || [[ "$desc" == *"clear"* ]] || [[ "$desc" == *"sunny"* ]]; then
    echo "􀆮"  # sun.max.fill
  # Partly cloudy
  elif [[ "$code" == "116" ]] || [[ "$desc" == *"partly cloudy"* ]] || [[ "$desc" == *"partly"* ]]; then
    echo "􀇂"  # cloud.sun.fill
  # Cloudy
  elif [[ "$code" == "119" ]] || [[ "$desc" == *"cloudy"* ]] || [[ "$desc" == *"overcast"* ]]; then
    echo "􀇊"  # cloud.fill
  # Rain
  elif [[ "$code" =~ ^(176|179|200|185|230|284|293|296|299|302|305|308|311|314|353|356|359|362|365)$ ]] || \
       [[ "$desc" == *"rain"* ]] || [[ "$desc" == *"drizzle"* ]] || [[ "$desc" == *"shower"* ]]; then
    echo "􀇈"  # cloud.rain.fill
  # Thunderstorm
  elif [[ "$code" =~ ^(200|201|202|230|231|232|233)$ ]] || [[ "$desc" == *"thunder"* ]] || [[ "$desc" == *"storm"* ]]; then
    echo "􀇎"  # cloud.bolt.fill
  # Snow
  elif [[ "$code" =~ ^(227|230|260|261|262|263|264|281|285|286|311|313|317|320|321|326|329|330|331|332|338|350|368|369|371|375|377|378|379)$ ]] || \
       [[ "$desc" == *"snow"* ]] || [[ "$desc" == *"sleet"* ]]; then
    echo "􀇥"  # cloud.snow.fill
  # Fog/Mist
  elif [[ "$code" =~ ^(143|248|260)$ ]] || [[ "$desc" == *"fog"* ]] || [[ "$desc" == *"mist"* ]] || [[ "$desc" == *"haze"* ]]; then
    echo "􀇬"  # cloud.fog.fill
  # Windy
  elif [[ "$desc" == *"wind"* ]]; then
    echo "􀇧"  # wind
  # Default
  else
    echo "􀇬"  # cloud.fog.fill (default)
  fi
}

WEATHER_ICON=$(get_weather_icon "$WEATHER_CODE" "$WEATHER_DESCRIPTION")

sketchybar --set "$NAME" \
  label="${TEMPERATURE}°C • $WEATHER_DESCRIPTION${WIND_INFO}" \
  icon="$WEATHER_ICON" \
  icon.color=0xff5edaff
