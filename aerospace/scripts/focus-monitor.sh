#!/bin/bash

# Focus a monitor based on VAR1 variable (1, 2, or 3)
# Usage: VAR1=1 /bin/bash focus-monitor.sh
# Or from BTT: pass VAR1 as environment variable

# Get monitor number from VAR1, default to 1 if not set
MON_NUM="${VAR1:-1}"

# Map monitor number to monitor name
case "$MON_NUM" in
    1)
        MONITOR_NAME="HP E24u G4"
        ;;
    2)
        MONITOR_NAME="LG ULTRAFINE"
        ;;
    3)
        MONITOR_NAME="S24C31x"
        ;;
    *)
        echo "Error: VAR1 must be 1, 2, or 3. Got: $MON_NUM" >&2
        exit 1
        ;;
esac

# Focus the monitor
aerospace focus-monitor "$MONITOR_NAME"


