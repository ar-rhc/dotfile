local colors = require("colors")

sbar.bar({
  height = 39,
  color = colors.bar.bg,
  shadow = true,
  position = "top",
  sticky = true,
  padding_right = 9,
  padding_left = 9,
  corner_radius = 9,
  y_offset = 0,
  margin = 2,
  blur_radius = 20,
  notch_width = 0,
})
