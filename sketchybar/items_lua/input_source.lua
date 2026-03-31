local colors = require("colors")
local settings = require("settings")

local input = sbar.add("item", "input_source", {
  position = "right",
  icon = {
    font = { family = settings.font.text, style = "Regular", size = 20.0 },
    color = colors.white,
    padding_left = 2,
    padding_right = 2,
  },
  padding_left = 3,
  padding_right = 0,
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
  sbar.exec("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | plutil -convert xml1 -o - - | grep -A1 'KeyboardLayout Name' | tail -n1 | cut -d '>' -f2 | cut -d '<' -f1", function(result)
    result = result:gsub("%s+", "")
    if result == "ABC" then
      input:set({ icon = { string = "􀂕" } })
    else
      input:set({ icon = { string = "􀂙" } })
    end
  end)
end)
