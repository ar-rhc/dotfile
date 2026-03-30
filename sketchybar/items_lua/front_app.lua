local front_app = sbar.add("item", "front_app", {
  icon = {
    font = { family = "sketchybar-app-font", style = "Regular", size = 16.0 },
    drawing = true,
  },
  label = {
    font = { family = "SF Pro", style = "Black", size = 13.0 },
  },
  display = "active",
  click_script = "open -a 'Mission Control'",
})

front_app:subscribe("front_app_switched", function(env)
  sbar.exec("$CONFIG_DIR/plugins/icon_map.sh '" .. env.INFO .. "'", function(icon)
    front_app:set({
      label = { string = env.INFO },
      icon = { string = icon },
    })
  end)
end)
