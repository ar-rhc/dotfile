#!/bin/bash
#
# Accurate moon phase calculator for Übersicht widget
# Uses proper astronomical algorithms
#

do_fail() {
  echo "{ \"error\": true, \"message\": \"$1\" }"
  exit 1
}

# Get location - Auckland coordinates
CITY="Auckland"
REGION="NZ"
LAT=-36.85
LON=174.76

# If arguments provided, use them
if [ $# -eq 2 ]; then
  CITY="$1"
  REGION="$2"
fi

# Use Python for accurate astronomical calculations
python3 - <<'PYTHON_EOF'
import sys
from datetime import datetime, timedelta
import math

def julian_date(dt):
    """Convert datetime to Julian Date"""
    a = (14 - dt.month) // 12
    y = dt.year + 4800 - a
    m = dt.month + 12 * a - 3
    jdn = dt.day + (153 * m + 2) // 5 + 365 * y + y // 4 - y // 100 + y // 400 - 32045
    jd = jdn + (dt.hour - 12) / 24 + dt.minute / 1440 + dt.second / 86400
    return jd

def moon_phase(jd):
    """Calculate moon phase from Julian Date
    Returns phase (0-1) where 0=new moon, 0.5=full moon"""
    # Constants
    SYNODIC_MONTH = 29.530588853
    NEW_MOON_JD = 2451550.1  # Known new moon: Jan 6, 2000
    
    # Days since known new moon
    days_since = jd - NEW_MOON_JD
    
    # Calculate phase (0-1)
    phase = (days_since % SYNODIC_MONTH) / SYNODIC_MONTH
    
    # Calculate moon age in days
    moon_age = days_since % SYNODIC_MONTH
    
    return phase, moon_age

def illumination(phase):
    """Calculate illumination percentage from phase"""
    # phase is 0-1, where 0=new, 0.5=full
    # illumination follows cosine curve
    illum = (1 - math.cos(phase * 2 * math.pi)) / 2
    return illum * 100

def phase_name(phase):
    """Get phase name from phase value (0-1)"""
    phase_names = [
        (0.03125, "New Moon"),
        (0.21875, "Waxing Crescent"),
        (0.28125, "First Quarter"),
        (0.46875, "Waxing Gibbous"),
        (0.53125, "Full Moon"),
        (0.71875, "Waning Gibbous"),
        (0.78125, "Last Quarter"),
        (0.96875, "Waning Crescent"),
        (1.00000, "New Moon")
    ]
    
    for threshold, name in phase_names:
        if phase < threshold:
            return name
    return "New Moon"

def next_phase_date(current_jd, target_phase):
    """Find the next occurrence of a specific phase
    target_phase: 0=new, 0.25=first quarter, 0.5=full, 0.75=last quarter"""
    SYNODIC_MONTH = 29.530588853
    
    current_phase, _ = moon_phase(current_jd)
    
    # Calculate days to target phase
    if target_phase >= current_phase:
        days_to_phase = (target_phase - current_phase) * SYNODIC_MONTH
    else:
        days_to_phase = (1 - current_phase + target_phase) * SYNODIC_MONTH
    
    target_jd = current_jd + days_to_phase
    return target_jd

def jd_to_datetime(jd):
    """Convert Julian Date to datetime"""
    jd = jd + 0.5
    z = int(jd)
    f = jd - z
    
    if z < 2299161:
        a = z
    else:
        alpha = int((z - 1867216.25) / 36524.25)
        a = z + 1 + alpha - alpha // 4
    
    b = a + 1524
    c = int((b - 122.1) / 365.25)
    d = int(365.25 * c)
    e = int((b - d) / 30.6001)
    
    day = b - d - int(30.6001 * e) + f
    month = e - 1 if e < 14 else e - 13
    year = c - 4716 if month > 2 else c - 4715
    
    hour = (day - int(day)) * 24
    minute = (hour - int(hour)) * 60
    second = (minute - int(minute)) * 60
    
    return datetime(int(year), int(month), int(day), int(hour), int(minute), int(second))

# Get current date/time
now = datetime.utcnow()
jd = julian_date(now)

# Calculate moon phase
phase, moon_age = moon_phase(jd)
illum = illumination(phase)
current_phase_name = phase_name(phase)

# Find next full moon
next_full_jd = next_phase_date(jd, 0.5)
next_full_dt = jd_to_datetime(next_full_jd)

# Find closest major phase
phases_to_check = [
    (0.0, "New Moon"),
    (0.25, "First Quarter"),
    (0.5, "Full Moon"),
    (0.75, "Last Quarter")
]

closest_phase_name = None
closest_days = 999
closest_date = None

for target_phase, name in phases_to_check:
    # Check previous occurrence
    if target_phase <= phase:
        days_ago = (phase - target_phase) * 29.530588853
        if days_ago < closest_days:
            closest_days = days_ago
            closest_phase_name = name
            closest_date = jd_to_datetime(jd - days_ago)
    
    # Check next occurrence
    next_jd = next_phase_date(jd, target_phase)
    days_until = next_jd - jd
    if days_until < closest_days:
        closest_days = days_until
        closest_phase_name = name
        closest_date = jd_to_datetime(next_jd)

# Output JSON
print(f'''{{
  "error": false,
  "city": "Auckland",
  "region": "NZ",
  "lat": -36.85,
  "lon": 174.76,
  "illum": "{int(round(illum))}",
  "curphase": "{current_phase_name}",
  "closestphase": {{
    "phase": "{closest_phase_name}",
    "date": "{closest_date.strftime('%Y-%m-%d')}",
    "time": "{closest_date.strftime('%H:%M')}"
  }}
}}''')
PYTHON_EOF