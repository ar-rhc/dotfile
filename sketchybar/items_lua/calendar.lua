local colors = require("colors")
local settings = require("settings")

local cal = sbar.add("item", "calendar", {
  position = "right",
  icon = {
    font = { family = settings.font.text, style = "Black", size = 18.0 },
    padding_right = 0,
  },
  label = { align = "right" },
  update_freq = 60,
  click_script = "$CONFIG_DIR/plugins/zen.sh",
})

cal:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/calendar.sh")
end)
