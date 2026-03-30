local colors = require("colors")
local settings = require("settings")

local input = sbar.add("item", "input_source", {
  position = "right",
  icon = {
    font = { family = settings.font.text, style = "Regular", size = 20.0 },
    color = colors.white,
  },
  update_freq = 1,
  updates = "on",
  click_script = [[
    CURRENT=$(macism)
    ENGLISH="com.apple.keylayout.ABC"
    CHINESE="com.apple.inputmethod.SCIM.ITABC"
    if [ "$CURRENT" = "$ENGLISH" ]; then macism $CHINESE; else macism $ENGLISH; fi
  ]],
})

input:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/get_input_source.sh'")
end)
