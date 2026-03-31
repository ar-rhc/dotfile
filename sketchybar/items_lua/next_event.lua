local colors = require("colors")
local settings = require("settings")

-- Configuration
local EXCLUDE_CALENDARS = "Shorebird Centre Tides & Events, Tiritiri Ferry Schedule"
local MAX_TITLE = 20
local LOOKAHEAD_DAYS = 1

local next_event = sbar.add("item", "next_event", {
  position = "right",
  icon = { string = "􀧞" },
  padding_left = 3,
  padding_right = 3,
  display = 2,
  update_freq = 60,
  updates = "on",
  click_script = "/Users/alex/.config/sketchybar/plugins/scripts/next_event_click.sh",
})

local function truncate(s, max)
  if #s > max then return s:sub(1, max) .. "..." end
  return s
end

local function format_remaining(seconds, prefix)
  seconds = math.max(0, math.floor(seconds))
  local hours = math.floor(seconds / 3600)
  local mins = math.floor((seconds % 3600) / 60)
  if hours > 0 then
    return "•" .. prefix .. " " .. hours .. "hr " .. mins .. "min"
  else
    return "•" .. prefix .. " " .. mins .. "min"
  end
end

local function parse_timestamp(date_str, time_str)
  -- date_str: "2026-03-31", time_str: "19:00"
  local y, m, d = date_str:match("(%d+)-(%d+)-(%d+)")
  local hr, mn = time_str:match("(%d+):(%d+)")
  if not y or not hr then return nil end
  return os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d),
                    hour = tonumber(hr), min = tonumber(mn), sec = 0 })
end

local function update_event()
  local cmd = 'icalBuddy -n -nc -ec "' .. EXCLUDE_CALENDARS .. '" -iep "datetime,title" -po "datetime,title" -ps "|^|" -tf "%H:%M" -df "%Y-%m-%d" -nrd -b "" -ea eventsToday+' .. LOOKAHEAD_DAYS .. ' 2>/dev/null'

  sbar.exec(cmd, function(result)
    result = result:gsub("%s+$", "")
    if result == "" or result:match("error:") then
      next_event:set({ label = { string = result:match("No calendars") and "No calendar access" or "" } })
      return
    end

    local now = os.time()
    local today = os.date("%Y-%m-%d")
    local best_type, best_title, best_start, best_end
    local current_title, current_start, current_end
    local next_title, next_start, next_end

    for line in result:gmatch("[^\n]+") do
      -- Parse: "2026-03-31 at 19:00 - 20:00^Title"
      local datetime, title = line:match("^(.-)%^(.+)")
      if datetime and title then
        local date_str = datetime:match("^(%d%d%d%d%-%d%d%-%d%d)")
        local start_time = datetime:match("at (%d+:%d+)")
        local end_time = datetime:match("- (%d+:%d+)")

        if date_str and start_time then
          local start_sec = parse_timestamp(date_str, start_time)
          local end_sec = end_time and parse_timestamp(date_str, end_time) or (start_sec and start_sec + 3600)

          if start_sec and end_sec then
            -- Current event (ongoing)
            if start_sec <= now and end_sec > now then
              if not current_start or start_sec > current_start then
                current_title, current_start, current_end = title, start_sec, end_sec
              end
            end

            -- Next upcoming event
            if start_sec > now then
              local event_date = os.date("%Y-%m-%d", start_sec)
              local hours_until = (start_sec - now) / 3600
              if event_date == today or hours_until <= 10 then
                if not next_start or start_sec < next_start then
                  next_title, next_start, next_end = title, start_sec, end_sec
                end
              end
            end
          end
        end
      end
    end

    -- Priority: next overlapping current > current > next
    if current_title and next_title and next_start < current_end then
      best_type, best_title, best_start, best_end = "next", next_title, next_start, next_end
    elseif current_title then
      best_type, best_title, best_start, best_end = "current", current_title, current_start, current_end
    elseif next_title then
      best_type, best_title, best_start, best_end = "next", next_title, next_start, next_end
    end

    if not best_title then
      next_event:set({ label = { string = "" }, drawing = false })
      return
    end

    local label
    if best_type == "current" then
      local left = best_end - now
      label = truncate(best_title, MAX_TITLE) .. " " .. format_remaining(left, "")
      label = label:gsub("•  ", "•"):gsub("• ", "•")
      label = truncate(best_title, MAX_TITLE) .. " •" .. math.floor(left / 60) .. "min left"
    else
      local until_start = best_start - now
      label = truncate(best_title, MAX_TITLE) .. " " .. format_remaining(until_start, "in")
    end

    next_event:set({ label = { string = label }, drawing = true })
  end)
end

next_event:subscribe({ "routine", "forced", "system_woke" }, function()
  update_event()
end)

update_event()
