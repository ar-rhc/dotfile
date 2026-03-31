local colors = require("colors")
local settings = require("settings")
local icon_map = require("icon_map")

local apps = {
  { name = "mail",     bundle = "com.apple.mail",        display = "Mail" },
  { name = "messages", bundle = "com.apple.MobileSMS",   display = "Messages" },
  { name = "whatsapp", bundle = "net.whatsapp.WhatsApp", display = "WhatsApp" },
  { name = "wechat",   bundle = "com.tencent.xinWeChat", display = "WeChat" },
}

-- Create notification items
for _, a in ipairs(apps) do
  sbar.add("item", "notif." .. a.name, {
    position = "right",
    drawing = false,
    width = 0,
    padding_left = 0,
    padding_right = 0,
    icon = {
      string = icon_map.get(a.display),
      font = { family = "sketchybar-app-font", style = "Regular", size = 16.0 },
      color = colors.white,
      padding_left = 10,
      padding_right = 2,
    },
    label = {
      color = colors.white,
      font = { family = settings.font.text, style = "Bold", size = 14.0 },
      padding_right = 10,
    },
    background = {
      color = 0x80494949,
      corner_radius = 9,
      height = 26,
    },
    click_script = "open -a '" .. a.display .. "'",
  })
end

-- Hidden trigger item
local trigger = sbar.add("item", "notifications", {
  position = "right",
  updates = "on",
  update_freq = 5,
  width = 0,
  padding_left = 0,
  padding_right = 0,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
})

-- Build a single shell command that checks all badges and sets items directly
-- This bypasses sbar.exec callback issues with empty/slow output
local function build_check_cmd()
  local cmd = ""
  for _, a in ipairs(apps) do
    local icon = icon_map.get(a.display)
    cmd = cmd .. string.format(
      [[badge=$(lsappinfo info -only StatusLabel '%s' 2>/dev/null | grep -o '"label"="[^"]*"' | cut -d'"' -f4); ]] ..
      [[if [ -n "$badge" ] && [ "$badge" != " " ]; then ]] ..
      [[sketchybar --set notif.%s drawing=on width=-1 label="$badge" icon='%s' icon.font="sketchybar-app-font:Regular:16.0"; ]] ..
      [[else sketchybar --set notif.%s drawing=off width=0; fi; ]],
      a.bundle, a.name, icon, a.name
    )
  end
  return cmd
end

local check_cmd = build_check_cmd()

trigger:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec(check_cmd .. " &")
end)
