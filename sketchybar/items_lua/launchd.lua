local colors = require("colors")
local settings = require("settings")

local launchd = sbar.add("item", "launchd", {
  position = "right",
  display = require("displays").lg,
  icon = {
    string = "􀢺",
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    color = colors.white,
  },
  label = { drawing = false },
  padding_left = 3,
  padding_right = 3,
  popup = { height = 30, background = { border_width = 0 } },
})

-- Discover com.alex.* plists and create popup items
local popup_items = {}
local popup_width = 280

local function refresh_plists()
  sbar.exec("ls ~/Library/LaunchAgents/com.alex.*.plist 2>/dev/null | xargs -I{} basename {} .plist", function(result)
    result = result:gsub("%s+$", "")
    if result == "" then return end

    local labels = {}
    for label in result:gmatch("[^\n]+") do
      table.insert(labels, label)
    end

    -- Build status for each plist
    for i, label in ipairs(labels) do
      local item_name = "launchd.item" .. i

      if not popup_items[i] then
        popup_items[i] = sbar.add("item", item_name, {
          position = "popup.launchd",
          icon = {
            font = { family = settings.font.text, style = "Regular", size = 12.0 },
            width = 20,
            align = "center",
          },
          label = {
            font = { family = settings.font.text, style = "Regular", size = 12.0 },
            width = popup_width - 20,
          },
        })
        -- Click toggles the service
        popup_items[i]:subscribe("mouse.clicked", function(env)
          local lbl = labels[i]
          if not lbl then return end
          sbar.exec("launchctl list '" .. lbl .. "' 2>/dev/null | grep '\"PID\"'", function(pid_line)
            if pid_line and pid_line:match("%d+") then
              sbar.exec("launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/" .. lbl .. ".plist 2>&1")
            else
              sbar.exec("launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/" .. lbl .. ".plist 2>&1")
            end
            sbar.delay(1, refresh_plists)
          end)
        end)
      end

      -- Query status and last trigger time
      local cmd = "launchctl list '" .. label .. "' 2>/dev/null"
      sbar.exec(cmd, function(info)
        local pid = info:match('"PID" = (%d+)')
        local exit_code = info:match('"LastExitStatus" = (%d+)')
        local stdout = info:match('"StandardOutPath" = "([^"]+)"')
        local short_name = label:gsub("^com%.alex%.", "")

        local status_icon, status_color
        if pid then
          status_icon = "􀁣"
          status_color = colors.green
        elseif exit_code == "0" then
          status_icon = "􀁡"
          status_color = colors.grey
        else
          status_icon = "􀁠"
          status_color = colors.red
        end

        -- Get last trigger time from log file mtime
        local time_cmd = "echo none"
        if stdout then
          time_cmd = "stat -f '%Sm' -t '%m/%d %H:%M' '" .. stdout .. "' 2>/dev/null || echo none"
        end
        sbar.exec(time_cmd, function(mtime)
          mtime = mtime:gsub("%s+$", "")
          local display = short_name
          if mtime ~= "none" then
            display = short_name .. "  " .. mtime
          end
          popup_items[i]:set({
            icon = { string = status_icon, color = status_color },
            label = { string = display },
          })
        end)
      end)
    end
  end)
end

launchd:subscribe("mouse.clicked", function()
  sbar.exec("sketchybar --trigger close_popups OPENER=launchd")
  refresh_plists()
  launchd:set({ popup = { drawing = "toggle" } })
end)

launchd:subscribe("close_popups", function(env)
  if env.OPENER ~= "launchd" then launchd:set({ popup = { drawing = false } }) end
end)
launchd:subscribe("mouse.exited.global", function()
  launchd:set({ popup = { drawing = false } })
end)

refresh_plists()
