local settings = require("settings")

local next_event = sbar.add("item", "next_event", {
  position = "right",
  icon = { string = "􀧞" },
  padding_left = 5,
  padding_right = 5,
  display = "active",
  update_freq = 60,
  click_script = "$CONFIG_DIR/plugins/scripts/next_event_click.sh",
})

next_event:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/next_event.sh")
end)
