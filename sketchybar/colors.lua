local colors = {
  black = 0xff000000,
  white = 0xffffffff,
  red = 0xffff5555,
  green = 0xff50fa7b,
  blue = 0xff8be9fd,
  yellow = 0xfff1fa8c,
  orange = 0xffffb86c,
  magenta = 0xffff79c6,
  grey = 0xff6272a4,
  transparent = 0x00000000,

  bar = {
    bg = 0xa0000000,
    service = 0xa01a4a2a,
    app = 0xa04a1a4a,
  },
  popup = {
    bg = 0xff000000,
    border = 0xff50fa7b,
  },
  bg1 = 0x901a1a1a,
  bg2 = 0x902d2d2d,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}

return colors
