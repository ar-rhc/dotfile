local colors = require("colors")
local settings = require("settings")
local icon_map = require("icon_map")

local apps = {
  { name = "mail",     display = "Mail" },
  { name = "messages", display = "Messages" },
  { name = "whatsapp", display = "WhatsApp" },
  { name = "wechat",   display = "WeChat" },
}

-- Create notification items
for _, a in ipairs(apps) do
  sbar.add("item", "notif." .. a.name, {
    position = "right",
    display = require("displays").lg,
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
  display = require("displays").lg,
  updates = "on",
  update_freq = 5,
  width = 0,
  padding_left = 0,
  padding_right = 0,
  icon = { drawing = false },
  label = { drawing = false },
  background = { drawing = false },
})

-- Per-app badge check commands using methods that actually work
-- Mail: direct AppleScript query
-- Others: Dock accessibility badge
local mail_icon = icon_map.get("Mail")
local messages_icon = icon_map.get("Messages")
local whatsapp_icon = icon_map.get("WhatsApp")
local wechat_icon = icon_map.get("WeChat")

local check_cmd = [[
# Mail - use Mail.app AppleScript
mail_badge=$(osascript -e 'try
  tell application "Mail" to return unread count of inbox
end try' 2>/dev/null)
if [ -n "$mail_badge" ] && [ "$mail_badge" != "0" ] && [ "$mail_badge" != "missing value" ]; then
  sketchybar --set notif.mail drawing=on width=-1 label="$mail_badge" icon=']] .. mail_icon .. [[' icon.font="sketchybar-app-font:Regular:16.0"
else
  sketchybar --set notif.mail drawing=off width=0
fi

# Messages - Dock badge
msg_badge=$(osascript -e 'tell application "System Events" to tell process "Dock" to try
  return value of attribute "AXStatusLabel" of UI element "Messages" of list 1
end try' 2>/dev/null)
if [ -n "$msg_badge" ] && [ "$msg_badge" != "0" ] && [ "$msg_badge" != "missing value" ]; then
  sketchybar --set notif.messages drawing=on width=-1 label="$msg_badge" icon=']] .. messages_icon .. [[' icon.font="sketchybar-app-font:Regular:16.0"
else
  sketchybar --set notif.messages drawing=off width=0
fi

# WhatsApp - Dock badge
wa_badge=$(osascript -e 'tell application "System Events" to tell process "Dock" to try
  return value of attribute "AXStatusLabel" of UI element "WhatsApp" of list 1
end try' 2>/dev/null)
if [ -n "$wa_badge" ] && [ "$wa_badge" != "0" ] && [ "$wa_badge" != "missing value" ]; then
  sketchybar --set notif.whatsapp drawing=on width=-1 label="$wa_badge" icon=']] .. whatsapp_icon .. [[' icon.font="sketchybar-app-font:Regular:16.0"
else
  sketchybar --set notif.whatsapp drawing=off width=0
fi

# WeChat - Dock badge
wc_badge=$(osascript -e 'tell application "System Events" to tell process "Dock" to try
  return value of attribute "AXStatusLabel" of UI element "WeChat" of list 1
end try' 2>/dev/null)
if [ -n "$wc_badge" ] && [ "$wc_badge" != "0" ] && [ "$wc_badge" != "missing value" ]; then
  sketchybar --set notif.wechat drawing=on width=-1 label="$wc_badge" icon=']] .. wechat_icon .. [[' icon.font="sketchybar-app-font:Regular:16.0"
else
  sketchybar --set notif.wechat drawing=off width=0
fi
]]

trigger:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec(check_cmd .. " &")
end)
