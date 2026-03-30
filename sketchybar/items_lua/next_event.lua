local next_event = sbar.add("item", "next_event", {
  position = "right",
  icon = { string = "􀧞" },
  padding_left = 3,
  padding_right = 3,
  display = 2,
  update_freq = 60,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/scripts/next_event_click.sh",
})

local function update_event()
  sbar.exec("NAME=next_event CONFIG_DIR=/Users/alex/.config/sketchybar SENDER=routine /Users/alex/.config/sketchybar/plugins/next_event.sh")
end

next_event:subscribe({ "routine", "forced", "system_woke" }, function() update_event() end)
update_event()
