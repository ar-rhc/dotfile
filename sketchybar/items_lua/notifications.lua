local colors = require("colors")
local settings = require("settings")

local apps = {
  { name = "mail",     bundle = "com.apple.mail",        app = "Mail",     display = "Mail" },
  { name = "messages", bundle = "com.apple.MobileSMS",   app = "Messages", display = "Messages" },
  { name = "whatsapp", bundle = "net.whatsapp.WhatsApp", app = "WhatsApp", display = "WhatsApp" },
  { name = "wechat",   bundle = "com.tencent.xinWeChat", app = "WeChat",   display = "WeChat" },
}

-- Create notification items
local notif_items = {}
for _, a in ipairs(apps) do
  local item = sbar.add("item", "notif." .. a.name, {
    position = "right",
    drawing = false,
    width = 0,
    padding_left = 0,
    padding_right = 0,
    icon = {
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
  notif_items[a.name] = { item = item, app = a }
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

-- Check badges using lsappinfo
local function check_badge(bundle_id, callback)
  sbar.exec("lsappinfo info -only StatusLabel '" .. bundle_id .. "' 2>/dev/null | grep -o '\"label\"=\"[^\"]*\"' | cut -d'\"' -f4", function(badge)
    badge = badge:gsub("%s+$", ""):gsub("^%s+", "")
    if badge == "" or badge == " " then
      callback(nil)
    else
      callback(badge)
    end
  end)
end

local function update_notif(name, badge)
  local ni = notif_items[name]
  if not ni then return end
  if badge then
    sbar.exec("/Users/alex/.config/sketchybar/plugins/icon_map.sh '" .. ni.app.display .. "'", function(icon)
      icon = icon:gsub("%s+$", "")
      ni.item:set({
        icon = { string = icon },
        label = { string = badge },
        drawing = true,
        width = "dynamic",
      })
    end)
  else
    ni.item:set({ drawing = false, width = 0 })
  end
end

trigger:subscribe({ "routine", "forced", "system_woke" }, function()
  for _, a in ipairs(apps) do
    check_badge(a.bundle, function(badge)
      update_notif(a.name, badge)
    end)
  end
end)
