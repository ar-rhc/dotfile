local colors = require("colors")
local settings = require("settings")

local COUNT_FILE = "/tmp/sketchybar_brew_count"

local brew = sbar.add("item", "brew", {
  position = "right",
  icon = {
    string = "􀐛",
    color = colors.yellow,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
  },
  label = {
    font = { family = settings.font.numbers, style = "Regular", size = 12.0 },
  },
  padding_left = 3,
  padding_right = 3,
  update_freq = 3600,
  updates = "on",
})

-- Read count and update via sketchybar CLI (bypasses io.open issues in event loop)
brew:subscribe({ "routine", "forced", "system_woke" }, function()
  sbar.exec("cat " .. COUNT_FILE .. " 2>/dev/null || echo 0", function(count)
    -- sbar.exec callback may return empty, use sketchybar CLI as fallback
  end)
  sbar.exec("count=$(cat " .. COUNT_FILE .. " 2>/dev/null || echo 0); if [ \"$count\" -gt 0 ] 2>/dev/null; then sketchybar --set brew label=\"$count\" drawing=on; else sketchybar --set brew drawing=off; fi &")
end)

brew:subscribe("mouse.clicked", function()
  sbar.exec("open -a Terminal")
end)

-- Seed count at init (os.execute runs before SIGCHLD is modified)
os.execute("/Users/alex/.config/sketchybar/plugins/brew_check.sh &")
-- Read after delay
sbar.delay(5, function()
  sbar.exec("count=$(cat " .. COUNT_FILE .. " 2>/dev/null || echo 0); if [ \"$count\" -gt 0 ] 2>/dev/null; then sketchybar --set brew label=\"$count\" drawing=on; else sketchybar --set brew drawing=off; fi &")
end)
