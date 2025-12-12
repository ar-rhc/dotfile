#!/bin/bash

# Try to source theme file, or use default Rose Pine colors
if [ -f ~/.config/themes/rose-pine.sh ]; then
    source ~/.config/themes/rose-pine.sh
else
    # Default Rose Pine color values (Rosé Pine variant)
    export BASE="191724"
    export SURFACE="1f1d2e"
    export GOLD="f6c177"
    export TEXT="e0def4"
    export IRIS="c4a7e7"
    export SUBTLE="908caa"
    export MUTED="6e6a86"
    export PINE="31748f"
    export LOVE="eb6f92"
fi

export BAR_COLOR="0x50$BASE"     # base
export ITEM_BG_COLOR="0x60$SURFACE" # surface
export ACCENT_COLOR="0xff$GOLD"  # gold
export TEXT_COLOR="0xff$TEXT"    # text
export ITEM_LABEL_COLOR="0xff$IRIS"

# Semantic color variables for theming
export INACTIVE_COLOR="0xFF$SUBTLE"  # borders and inactive backgrounds
export MUTED_COLOR="0xFF$MUTED"      # inactive labels and secondary text
export SUCCESS_COLOR="0xFF$PINE"     # good status (low usage)
export WARNING_COLOR="0xFF$GOLD"     # medium status
export ERROR_COLOR="0xFF$LOVE"       # critical status

# Icon text color (BASE for both dark and light mode)
export ICON_TEXT_COLOR="0xff$BASE"
