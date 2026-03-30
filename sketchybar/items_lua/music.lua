local settings = require("settings")

-- Start the music monitor if not running
sbar.exec("pgrep -f '$CONFIG_DIR/plugins/music/music_monitor_file' || $CONFIG_DIR/plugins/music/music_monitor_file &")

local music = sbar.add("item", "music", {
  position = "center",
  icon = { font = { family = settings.font.text, style = "Regular", size = 14.0 } },
  label = { font = { family = settings.font.text, style = "Semibold", size = 13.0 } },
  drawing = false,
  updates = "on",
  update_freq = 2,
  click_script = "$CONFIG_DIR/plugins/music/music_click.sh",
  popup = { height = 35, background = { border_width = 0 } },
})

music:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("$CONFIG_DIR/plugins/music/music.sh")
end)

music:subscribe("mouse.exited.global", function()
  music:set({ popup = { drawing = false } })
end)

-- Popup help items
local popup_off = "sketchybar --set music popup.drawing=off"
local commands = {
  { name = "cmd_playpause", label = "Left Click - Play/Pause" },
  { name = "cmd_next",      label = "Opt + Left Click - Next Track" },
  { name = "cmd_prev",      label = "Ctrl + Left Click - Previous Track" },
  { name = "cmd_open",      label = "Cmd + Left Click - Open Music" },
}

for _, cmd in ipairs(commands) do
  sbar.add("item", "music." .. cmd.name, {
    position = "popup.music",
    label = { string = cmd.label },
    click_script = popup_off,
  })
end
