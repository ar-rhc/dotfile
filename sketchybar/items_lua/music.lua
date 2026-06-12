local colors = require("colors")
local settings = require("settings")

local INFO_FILE = "/tmp/music_info.txt"
local MONITOR = "/Users/alex/.config/sketchybar/plugins/music/music_monitor_file"

local music = sbar.add("item", "music", {
  position = "center",
  icon = { font = { family = settings.font.text, style = "Regular", size = 14.0 } },
  label = { font = { family = settings.font.text, style = "Semibold", size = 13.0 } },
  drawing = false,
  updates = "on",
  update_freq = 2,
  popup = { height = 35, background = { border_width = 0 } },
})

-- Ensure monitor is running
sbar.exec("pgrep -f music_monitor_file || " .. MONITOR .. " &")

local function update_music()
  sbar.exec("pgrep -x Music > /dev/null && echo running || echo stopped", function(status)
    status = status:gsub("%s+", "")
    if status ~= "running" then
      music:set({ drawing = false })
      return
    end

    sbar.exec("pgrep -f music_monitor_file || " .. MONITOR .. " &")

    local f = io.open(INFO_FILE, "r")
    if not f then
      music:set({ drawing = false })
      return
    end

    local content = f:read("*a")
    f:close()

    local title = content:match("title:([^\n]+)")
    local artist = content:match("artist:([^\n]+)")
    local state = content:match("state:([^\n]+)")

    if title and title ~= "" then
      title = title:gsub("^%s+", ""):gsub("%s+$", "")
      artist = artist and artist:gsub("^%s+", ""):gsub("%s+$", "") or ""

      local icon = (state and state:match("Paused")) and "􀊘" or "􀊖"
      if #title > 20 then title = title:sub(1, 20) .. "…" end
      if #artist > 15 then artist = artist:sub(1, 15) .. "…" end

      local label = title
      if artist ~= "" then label = title .. " - " .. artist end

      music:set({ icon = { string = icon }, label = { string = label }, drawing = true })
    else
      music:set({ drawing = false })
    end
  end)
end

music:subscribe("routine", function() update_music() end)

music:subscribe("mouse.clicked", function(env)
  if env.MODIFIER == "alt" then
    sbar.exec([[osascript -e 'tell application "Music" to next track']])
  elseif env.MODIFIER == "ctrl" then
    sbar.exec([[osascript -e 'tell application "Music" to previous track']])
  elseif env.MODIFIER == "cmd" then
    sbar.exec("open -a Music")
  else
    sbar.exec([[osascript -e 'tell application "Music" to playpause']])
  end
  sbar.delay(0.5, function() update_music() end)
end)

music:subscribe("mouse.entered", function()
  sbar.exec("sketchybar --trigger close_popups OPENER=music")
  music:set({ popup = { drawing = true } })
end)

music:subscribe("close_popups", function(env)
  if env.OPENER ~= "music" then music:set({ popup = { drawing = false } }) end
end)
music:subscribe("mouse.exited.global", function()
  music:set({ popup = { drawing = false } })
end)

-- Popup help
local commands = {
  { name = "cmd_playpause", label = "Click - Play/Pause" },
  { name = "cmd_next",      label = "Opt+Click - Next Track" },
  { name = "cmd_prev",      label = "Ctrl+Click - Previous" },
  { name = "cmd_open",      label = "Cmd+Click - Open Music" },
}
for _, cmd in ipairs(commands) do
  sbar.add("item", "music." .. cmd.name, {
    position = "popup.music",
    label = { string = cmd.label, font = { family = settings.font.text, style = "Regular", size = 12.0 } },
    click_script = "sketchybar --set music popup.drawing=off",
  })
end
