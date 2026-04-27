local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local COUNT_FILE = "/tmp/sketchybar_nasa_new_count"
local GALLERY_DIR = "/Users/alex/Library/Mobile Documents/com~apple~CloudDocs/Pictures/NASA"

local nasa = sbar.add("item", "nasa_gallery", {
  position = "right",
  drawing = false,
  icon = {
    string = icons.nasa,
    color = colors.white,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
  },
  label = {
    font = { family = settings.font.numbers, style = "Regular", size = 12.0 },
  },
  padding_left = 3,
  padding_right = 3,
  update_freq = 60,
  updates = "on",
})

local function update_count()
  sbar.exec("cat " .. COUNT_FILE .. " 2>/dev/null || echo 0", function(count)
    count = count:gsub("%s+", "")
    local n = tonumber(count) or 0
    if n > 0 then
      sbar.exec("sketchybar --set nasa_gallery drawing=on label='" .. n .. "'")
    else
      sbar.exec("sketchybar --set nasa_gallery drawing=off")
    end
  end)
end

nasa:subscribe({ "routine", "forced", "system_woke" }, function()
  update_count()
end)

nasa:subscribe("mouse.clicked", function()
  sbar.exec("echo 0 > " .. COUNT_FILE)
  sbar.exec("sketchybar --set nasa_gallery drawing=off")
  sbar.exec("open '" .. GALLERY_DIR .. "'")
end)

sbar.delay(5, update_count)
