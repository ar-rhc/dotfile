local colors = require("colors")
local settings = require("settings")

sbar.default({
  updates = "when_shown",
  icon = {
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = { family = settings.font.text, style = "Semibold", size = 13.0 },
    color = colors.white,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
    shadow = { drawing = true, distance = 2, color = colors.black },
  },
  padding_right = settings.paddings,
  padding_left = settings.paddings,
  background = {
    height = 26,
    corner_radius = 9,
    border_width = 2,
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 9,
      border_color = colors.popup.border,
      color = colors.popup.bg,
      shadow = { drawing = true },
    },
    blur_radius = 20,
  },
  scroll_texts = true,
})
