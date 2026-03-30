local icons = require("icons")

local trash = sbar.add("item", "trash", {
  position = "right",
  drawing = false,
  icon = { string = icons.trash, color = 0xffff9966 },
  label = { padding_left = 0 },
  padding_left = 3,
  padding_right = 3,
  update_freq = 60,
  updates = "on",
})

trash:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("osascript -l JavaScript -e 'Application(\"Finder\").trash.items.length'", function(count)
    count = tonumber(count:gsub("%s+", "")) or 0
    if count > 0 then
      trash:set({ drawing = true, label = { string = tostring(count) } })
    else
      trash:set({ drawing = false })
    end
  end)
end)

trash:subscribe("mouse.clicked", function(env)
  sbar.exec("NAME=trash SENDER=mouse.clicked /bin/bash -c '/Users/alex/.config/sketchybar/plugins/trash.sh'")
end)
