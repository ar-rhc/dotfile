local icons = require("icons")

local trash = sbar.add("item", "trash", {
  position = "right",
  drawing = false,
  icon = { string = icons.trash, color = 0xffff9966 },
  label = { padding_left = 0 },
  update_freq = 60,
  updates = "on",
})

trash:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/trash.sh'")
end)

trash:subscribe("mouse.clicked", function(env)
  sbar.exec("/bin/bash -c 'export CONFIG_DIR=/Users/alex/.config/sketchybar; /Users/alex/.config/sketchybar/plugins/trash.sh'")
end)
