local icons = require("icons")

local trash = sbar.add("item", "trash", {
  position = "right",
  drawing = false,
  icon = { string = icons.trash, color = 0xffff9966 },
  label = { padding_left = 0 },
  update_freq = 60,
})

trash:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/trash.sh")
end)

trash:subscribe("mouse.clicked", function(env)
  sbar.exec("$CONFIG_DIR/plugins/trash.sh")
end)
