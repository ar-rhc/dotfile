local colors = require("colors")
local settings = require("settings")

local calendar_icons = {
  "􃌦","􃌧","􃌨","􃌩","􃌪","􃌫","􃌬","􃌭","􃌮","􃌯",
  "􃌰","􃌱","􃌲","􃌳","􃌴","􃌵","􃌶","􃌷","􃌸","􃌹",
  "􃌺","􃌻","􃌼","􃌽","􃌾","􃌿","􃍀","􃍁","􃍂","􃍃","􃍄",
}

local cal = sbar.add("item", "calendar", {
  position = "right",
  icon = {
    font = { family = settings.font.text, style = "Black", size = 18.0 },
    padding_right = 0,
  },
  label = { align = "right" },
  update_freq = 60,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/zen.sh",
})

cal:subscribe({ "routine", "forced", "system_woke" }, function(env)
  local day = tonumber(os.date("%d"))
  local icon = calendar_icons[day] or "􀉉"
  cal:set({
    icon = { string = icon },
    label = { string = os.date("%a %d %b - %H:%M") },
  })
end)
