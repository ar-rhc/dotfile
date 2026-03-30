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

next_event:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("NAME=next_event CONFIG_DIR=/Users/alex/.config/sketchybar /Users/alex/.config/sketchybar/plugins/next_event.sh")
end)
