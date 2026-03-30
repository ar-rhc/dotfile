-- Pre-add notification items (hidden by default)
local notif_apps = { "mail", "messages", "whatsapp", "wechat" }
for _, app in ipairs(notif_apps) do
  sbar.add("item", "notif." .. app, {
    position = "right",
    drawing = false,
    width = 0,
    padding_left = 0,
    padding_right = 0,
  })
end

-- Invisible trigger item
local notifications = sbar.add("item", "notifications", {
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

notifications:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("NAME=notifications CONFIG_DIR=/Users/alex/.config/sketchybar /Users/alex/.config/sketchybar/plugins/notifications.sh")
end)
