#!/usr/bin/env bash

# Test script for weather plugin
# Run this to debug weather data fetching

echo "=== Weather Plugin Test Script ==="
echo ""

# Source colors if available
if [ -f "$HOME/.config/sketchybar/colors.sh" ]; then
  source "$HOME/.config/sketchybar/colors.sh"
  echo "✓ Colors loaded"
else
  echo "⚠ Colors file not found, using defaults"
fi

# Test variables
LOCATION="Auckland"
REGION="NZ"
LANG="en"
NAME="weather"

echo "Location: $LOCATION, $REGION"
echo ""

# Properly escape spaces and construct the URL
LOCATION_ESCAPED="$(echo "$LOCATION" | sed 's/ /+/g')+$(echo "$REGION" | sed 's/ /+/g')"
URL="https://wttr.in/${LOCATION_ESCAPED}?0pq&format=j1&lang=${LANG}"

echo "Fetching weather data..."
echo "URL: $URL"
echo ""

# Add timeout to prevent long loading (5 seconds max)
WEATHER_JSON=$(curl -fsSL --max-time 5 "$URL")

# Check if we got data
if [ -z "$WEATHER_JSON" ]; then
  echo "❌ ERROR: No data received from API"
  echo "   Check your internet connection"
  exit 1
fi

echo "✓ Data received (${#WEATHER_JSON} characters)"
echo ""

# Check if valid JSON
if ! echo "$WEATHER_JSON" | jq . >/dev/null 2>&1; then
  echo "❌ ERROR: Invalid JSON received"
  echo "First 200 chars:"
  echo "$WEATHER_JSON" | head -c 200
  exit 1
fi

echo "✓ Valid JSON"
echo ""

# Extract values
TEMPERATURE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].temp_C // empty')
WEATHER_DESCRIPTION_RAW=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherDesc[0].value // empty')
WEATHER_CODE=$(echo "$WEATHER_JSON" | jq -r '.current_condition[0].weatherCode // empty')

# Truncate description if too long
if [ -n "$WEATHER_DESCRIPTION_RAW" ]; then
  WEATHER_DESCRIPTION=$(echo "$WEATHER_DESCRIPTION_RAW" | sed 's/\(.\{16\}\).*/\1.../')
else
  WEATHER_DESCRIPTION=""
fi

echo "=== Extracted Values ==="
echo "Temperature: '$TEMPERATURE'"
echo "Description (raw): '$WEATHER_DESCRIPTION_RAW'"
echo "Description (truncated): '$WEATHER_DESCRIPTION'"
echo "Weather Code: '$WEATHER_CODE'"
echo ""

# Check if values are valid
if [ -z "$TEMPERATURE" ] || [ "$TEMPERATURE" == "null" ]; then
  echo "❌ ERROR: Temperature is empty or null"
  echo "Full current_condition object:"
  echo "$WEATHER_JSON" | jq '.current_condition[0]'
  exit 1
fi

if [ -z "$WEATHER_DESCRIPTION" ] || [ "$WEATHER_DESCRIPTION" == "null" ]; then
  echo "❌ ERROR: Description is empty or null"
  echo "Full current_condition object:"
  echo "$WEATHER_JSON" | jq '.current_condition[0]'
  exit 1
fi

echo "✓ All values extracted successfully"
echo ""

# Test icon function
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

echo "=== Final Output ==="
echo "Icon: $WEATHER_ICON"
echo "Label: ${TEMPERATURE}°C • $WEATHER_DESCRIPTION"
echo ""

# Test sketchybar command (if sketchybar is running)
if command -v sketchybar &> /dev/null; then
  echo "=== Testing SketchyBar Update ==="
  echo "Updating weather item..."
  sketchybar --set weather \
    label="${TEMPERATURE}°C • $WEATHER_DESCRIPTION" \
    icon="$WEATHER_ICON" \
    icon.color=0xff5edaff
  echo "✓ SketchyBar updated"
else
  echo "⚠ SketchyBar not found, skipping bar update"
fi

echo ""
echo "=== Test Complete ==="

