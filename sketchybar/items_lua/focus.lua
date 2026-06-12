local colors = require("colors")

local focus = sbar.add("item", "focus", {
  position = "right",
  icon = { string = "󰍶", color = colors.magenta },
  label = { drawing = false },
  drawing = false,
  padding_left = 3,
  padding_right = 3,
  update_freq = 10,
  updates = "on",
})

focus:subscribe({ "routine", "forced", "system_woke" }, function(env)
  sbar.exec("defaults read com.apple.controlcenter 'NSStatusItem Visible FocusModes' 2>/dev/null || echo 0", function(result)
    result = result:gsub("%s+", "")
    if result == "1" then
      focus:set({ drawing = true })
    else
      focus:set({ drawing = false })
    end
  end)
end)

-- Click to open Focus settings
focus:subscribe("mouse.clicked", function(env)
  sbar.exec("open x-apple.systempreferences:com.apple.Focus")
end)
