local colors = require("colors")
local settings = require("settings")

local input = sbar.add("item", "input_source", {
  position = "right",
  icon = {
    font = { family = settings.font.text, style = "Regular", size = 20.0 },
    color = colors.white,
  },
  update_freq = 1,
  click_script = [[
    CURRENT=$(macism)
    ENGLISH="com.apple.keylayout.ABC"
    CHINESE="com.apple.inputmethod.SCIM.ITABC"
    if [ "$CURRENT" = "$ENGLISH" ]; then macism $CHINESE; else macism $ENGLISH; fi
  ]],
})

input:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/get_input_source.sh")
end)
