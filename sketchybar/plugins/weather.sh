#!/usr/bin/env bash

# Configuration
API_KEY="92d1dbd1f0ed49f392c195243260701" # insert api key here - get from https://www.weatherapi.com/signup.aspx
CACHE_FILE="/tmp/sketchybar_weather_cache.json"
CACHE_DURATION=1800  # Cache for 30 minutes (1800 seconds)

# Get city location (coordinates from IP)
CITY=$(curl -s ipinfo.io/loc 2>/dev/null || echo "Auckland")

# Function to get weather icon based on condition code and day/night
get_weather_icon() {
  local condition=$1
  local is_day=$2
  local icon=""
  
  # Ensure condition is treated as a number (remove any whitespace)
  condition=$(echo "$condition" | tr -d '[:space:]')
  is_day=$(echo "$is_day" | tr -d '[:space:]')
  
  if [ "$is_day" = "1" ]; then
    # Day icons
    case "$condition" in
      1000) icon="" ;;   # Sunny/113
      1003) icon="" ;;   # Partly cloudy/116
      1006) icon="" ;;   # Cloudy/119
      1009) icon="" ;;   # Overcast/122
      1030) icon="" ;;   # Mist/143
      1063) icon="" ;;   # Patchy rain possible/176
      1066) icon="" ;;   # Patchy snow possible/179
      1069) icon="" ;;   # Patchy sleet possible/182
      1072) icon="" ;;   # Patchy freezing drizzle possible/185
      1087) icon="" ;;   # Thundery outbreaks possible/200
      1114) icon="" ;;   # Blowing snow/227
      1117) icon="" ;;   # Blizzard/230
      1135) icon="" ;;   # Fog/248
      1147) icon="" ;;   # Freezing fog/260
      1150) icon="" ;;   # Patchy light drizzle/263
      1153) icon="" ;;   # Light drizzle/266
      1168) icon="" ;;   # Freezing drizzle/281
      1171) icon="" ;;   # Heavy freezing drizzle/284
      1180) icon="" ;;   # Patchy light rain/293
      1183) icon="" ;;   # Light rain/296
      1186) icon="" ;;   # Moderate rain at times/299
      1189) icon="" ;;   # Moderate rain/302
      1192) icon="" ;;   # Heavy rain at times/305
      1195) icon="" ;;   # Heavy rain/308
      1198) icon="" ;;   # Light freezing rain/311
      1201) icon="" ;;   # Moderate or heavy freezing rain/314
      1204) icon="" ;;   # Light sleet/317
      1207) icon="" ;;   # Moderate or heavy sleet/320
      1210) icon="" ;;   # Patchy light snow/323
      1213) icon="" ;;   # Light snow/326
      1216) icon="" ;;   # Patchy moderate snow/329
      1219) icon="" ;;   # Moderate snow/332
      1222) icon="" ;;   # Patchy heavy snow/335
      1225) icon="" ;;   # Heavy snow/338
      1237) icon="" ;;   # Ice pellets/350
      1240) icon="" ;;   # Light rain shower/353
      1243) icon="" ;;   # Moderate or heavy rain shower/356
      1246) icon="" ;;   # Torrential rain shower/359
      1249) icon="" ;;   # Light sleet showers/362
      1252) icon="" ;;   # Moderate or heavy sleet showers/365
      1255) icon="" ;;   # Light snow showers/368
      1258) icon="" ;;   # Moderate or heavy snow showers/371
      1261) icon="" ;;   # Light showers of ice pellets/374
      1264) icon="" ;;   # Moderate or heavy showers of ice pellets/377
      1273) icon="" ;;   # Patchy light rain with thunder/386
      1276) icon="" ;;   # Moderate or heavy rain with thunder/389
      1279) icon="" ;;   # Patchy light snow with thunder/392
      1282) icon="" ;;   # Moderate or heavy snow with thunder/395
      *) icon="􀇬" ;;      # Default fallback
    esac
  else
    # Night icons
    case "$condition" in
      1000) icon="" ;;   # Clear/113
      1003) icon="" ;;   # Partly cloudy/116
      1006) icon="" ;;   # Cloudy/119
      1009) icon="" ;;   # Overcast/122
      1030) icon="" ;;   # Mist/143
      1063) icon="" ;;   # Patchy rain possible/176
      1066) icon="" ;;   # Patchy snow possible/179
      1069) icon="" ;;   # Patchy sleet possible/182
      1072) icon="" ;;   # Patchy freezing drizzle possible/185
      1087) icon="" ;;   # Thundery outbreaks possible/200
      1114) icon="" ;;   # Blowing snow/227
      1117) icon="" ;;   # Blizzard/230
      1135) icon="" ;;   # Fog/248
      1147) icon="" ;;   # Freezing fog/260
      1150) icon="" ;;   # Patchy light drizzle/263
      1153) icon="" ;;   # Light drizzle/266
      1168) icon="" ;;   # Freezing drizzle/281
      1171) icon="" ;;   # Heavy freezing drizzle/284
      1180) icon="" ;;   # Patchy light rain/293
      1183) icon="" ;;   # Light rain/296
      1186) icon="" ;;   # Moderate rain at times/299
      1189) icon="" ;;   # Moderate rain/302
      1192) icon="" ;;   # Heavy rain at times/305
      1195) icon="" ;;   # Heavy rain/308
      1198) icon="" ;;   # Light freezing rain/311
      1201) icon="" ;;   # Moderate or heavy freezing rain/314
      1204) icon="" ;;   # Light sleet/317
      1207) icon="" ;;   # Moderate or heavy sleet/320
      1210) icon="" ;;   # Patchy light snow/323
      1213) icon="" ;;   # Light snow/326
      1216) icon="" ;;   # Patchy moderate snow/329
      1219) icon="" ;;   # Moderate snow/332
      1222) icon="" ;;   # Patchy heavy snow/335
      1225) icon="" ;;   # Heavy snow/338
      1237) icon="" ;;   # Ice pellets/350
      1240) icon="" ;;   # Light rain shower/353
      1243) icon="" ;;   # Moderate or heavy rain shower/356
      1246) icon="" ;;   # Torrential rain shower/359
      1249) icon="" ;;   # Light sleet showers/362
      1252) icon="" ;;   # Moderate or heavy sleet showers/365
      1255) icon="" ;;   # Light snow showers/368
      1258) icon="" ;;   # Moderate or heavy snow showers/371
      1261) icon="" ;;   # Light showers of ice pellets/374
      1264) icon="" ;;   # Moderate or heavy showers of ice pellets/377
      1273) icon="" ;;   # Patchy light rain with thunder/386
      1276) icon="" ;;   # Moderate or heavy rain with thunder/389
      1279) icon="" ;;   # Patchy light snow with thunder/392
      1282) icon="" ;;   # Moderate or heavy snow with thunder/395
      *) icon="􀇬" ;;      # Default fallback
    esac
  fi
  
  echo "$icon"
}

# URL encode the city name (skip encoding for coordinates, they work as-is)
if echo "$CITY" | grep -qE '^-?[0-9]+\.?[0-9]*,-?[0-9]+\.?[0-9]*$'; then
  # It's coordinates, use as-is
  CITY_ENCODED="$CITY"
else
  # It's a city name, try to encode it
  CITY_ENCODED=$(echo "$CITY" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3- 2>/dev/null || echo "$CITY")
fi

# Check if cache exists and is still valid
USE_CACHE=false
if [ -f "$CACHE_FILE" ]; then
  CACHE_AGE=$(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null)))
  if [ "$CACHE_AGE" -lt "$CACHE_DURATION" ]; then
    USE_CACHE=true
  fi
fi

# Fetch weather data (use cache or API)
if [ "$USE_CACHE" = true ]; then
  # Use cached data, but validate it first
  cached_data=$(cat "$CACHE_FILE" 2>/dev/null)
  # Check if cache has an error
  cache_error=$(echo "$cached_data" | jq -r '.error.message // empty' 2>/dev/null)
  if [ -n "$cache_error" ] && [ "$cache_error" != "null" ]; then
    # Cache has error, don't use it
    USE_CACHE=false
  else
    data="$cached_data"
    # Update in background for next time (only if CITY_ENCODED is set)
    if [ -n "$CITY_ENCODED" ]; then
      (curl -s --max-time 10 "https://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$CITY_ENCODED" > "$CACHE_FILE" 2>/dev/null &)
    fi
  fi
fi

if [ "$USE_CACHE" != true ]; then
  # Ensure CITY_ENCODED is set
  if [ -z "$CITY_ENCODED" ]; then
    CITY_ENCODED="Auckland"
  fi
  
  # Fetch new data
  data=$(curl -s --max-time 10 "https://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$CITY_ENCODED" 2>/dev/null)
  
  # Check if API call failed or returned an error
  if [ -z "$data" ] || [ "$data" = "null" ]; then
    # Try with fallback city
    CITY_ENCODED="Auckland"
    data=$(curl -s --max-time 10 "https://api.weatherapi.com/v1/current.json?key=$API_KEY&q=$CITY_ENCODED" 2>/dev/null)
  fi
  
  # Check for errors before saving to cache
  error_check=$(echo "$data" | jq -r '.error.message // empty' 2>/dev/null)
  if [ -z "$error_check" ] || [ "$error_check" = "null" ]; then
    # Save to cache if valid (no errors)
    if [ -n "$data" ] && [ "$data" != "null" ] && echo "$data" | jq . >/dev/null 2>&1; then
      echo "$data" > "$CACHE_FILE" 2>/dev/null
    fi
  fi
fi

# If still no data, try to use cache even if expired
if [ -z "$data" ] || [ "$data" = "null" ] || ! echo "$data" | jq . >/dev/null 2>&1; then
  if [ -f "$CACHE_FILE" ]; then
    data=$(cat "$CACHE_FILE" 2>/dev/null)
    if [ -z "$data" ] || [ "$data" = "null" ] || ! echo "$data" | jq . >/dev/null 2>&1; then
      sketchybar --set "$NAME" \
        label="Error" \
        icon=􀇬 \
        icon.color=0xff5edaff
      exit 0
    fi
  else
    sketchybar --set "$NAME" \
      label="Error" \
      icon=􀇬 \
      icon.color=0xff5edaff
    exit 0
  fi
fi

# Check for API errors in response (only if data exists and is valid JSON)
if echo "$data" | jq . >/dev/null 2>&1; then
  error_msg=$(echo "$data" | jq -r '.error.message // empty' 2>/dev/null)
  if [ -n "$error_msg" ] && [ "$error_msg" != "null" ]; then
    # Try to use cache if available
    if [ -f "$CACHE_FILE" ]; then
      data=$(cat "$CACHE_FILE" 2>/dev/null)
      if [ -z "$data" ] || [ "$data" = "null" ] || ! echo "$data" | jq . >/dev/null 2>&1; then
        sketchybar --set "$NAME" \
          label="API Error" \
          icon=􀇬 \
          icon.color=0xff5edaff
        exit 0
      fi
    else
      sketchybar --set "$NAME" \
        label="API Error" \
        icon=􀇬 \
        icon.color=0xff5edaff
      exit 0
    fi
  fi
fi

# Extract weather data - handle null values properly
condition=$(echo "$data" | jq -r '.current.condition.code // ""' 2>/dev/null | tr -d '[:space:]')
condition_text=$(echo "$data" | jq -r '.current.condition.text // ""' 2>/dev/null)
temp=$(echo "$data" | jq -r '.current.temp_c // ""' 2>/dev/null)
feelslike=$(echo "$data" | jq -r '.current.feelslike_c // ""' 2>/dev/null)
humidity=$(echo "$data" | jq -r '.current.humidity // ""' 2>/dev/null)
is_day=$(echo "$data" | jq -r '.current.is_day // ""' 2>/dev/null | tr -d '[:space:]')

# Check if we got valid data
if [ -z "$temp" ] || [ -z "$condition" ] || [ "$temp" = "null" ] || [ "$condition" = "null" ]; then
  sketchybar --set "$NAME" \
    label="Error" \
    icon=􀇬 \
    icon.color=0xff5edaff
  exit 0
fi

# Ensure temp is a valid number
if ! echo "$temp" | grep -qE '^-?[0-9]+\.?[0-9]*$'; then
  sketchybar --set "$NAME" \
    label="Error" \
    icon=􀇬 \
    icon.color=0xff5edaff
  exit 0
fi

# Get icon using function
icon=$(get_weather_icon "$condition" "$is_day")

# Fallback icon if condition code not found or icon is empty
if [ -z "$icon" ] || [ "$icon" = "" ]; then
  icon="􀇬"
fi

# Update sketchybar
sketchybar -m \
  --set "$NAME" \
    icon="$icon" \
    label="${temp}°C" \
    icon.color=0xff5edaff \
    icon.font="Hack Nerd Font:Regular:13.0"
