local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local MAX_PROJECTS = 10

local claude = sbar.add("item", "claude_projects", {
  position = "right",
  display = require("displays").lg,
  icon = {
    string = icons.claude,
    font = { family = settings.font.text, style = "Regular", size = 14.0 },
    color = colors.white,
  },
  label = { drawing = false },
  padding_left = 3,
  padding_right = 3,
  popup = { height = 30, background = { border_width = 0 } },
})

local popup_width = 280
local project_items = {}
local project_data = {}  -- { path, session_id }

for i = 1, MAX_PROJECTS do
  project_items[i] = sbar.add("item", "claude_projects.proj" .. i, {
    position = "popup.claude_projects",
    drawing = false,
    icon = {
      font = { family = settings.font.numbers, style = "Regular", size = 11.0 },
      color = colors.grey,
      width = 55,
      align = "right",
      padding_right = 5,
    },
    label = {
      font = { family = settings.font.text, style = "Regular", size = 12.0 },
      width = popup_width - 55,
    },
  })
  project_data[i] = {}

  local idx = i
  project_items[i]:subscribe("mouse.clicked", function()
    local d = project_data[idx]
    if not d.path then return end
    local escaped_path = d.path:gsub("'", "'\\''")
    sbar.exec("/Users/alex/Scripts/iterm-claude-resume.sh '" .. escaped_path .. "' " .. d.session_id)
    claude:set({ popup = { drawing = false } })
  end)
end

local function refresh()
  for i = 1, MAX_PROJECTS do
    project_items[i]:set({ drawing = false })
    project_data[i] = {}
  end

  sbar.exec("/Users/alex/Scripts/claude-projects-list.py", function(result)
    result = result:gsub("%s+$", "")
    if result == "" then
      project_items[1]:set({
        drawing = true,
        icon = { string = "" },
        label = { string = "No projects found", color = colors.grey },
      })
      return
    end

    local i = 1
    for line in result:gmatch("[^\n]+") do
      if i > MAX_PROJECTS then break end
      local path, short, rel, sid = line:match("^(.-)|(.-)|(.-)|(.+)")
      if path and short and sid then
        project_data[i] = { path = path, session_id = sid }
        project_items[i]:set({
          drawing = true,
          icon = { string = rel, color = colors.grey },
          label = { string = short, color = colors.white },
        })
        i = i + 1
      end
    end
  end)
end

claude:subscribe("mouse.clicked", function()
  sbar.exec("sketchybar --trigger close_popups OPENER=claude_projects")
  refresh()
  claude:set({ popup = { drawing = "toggle" } })
end)

claude:subscribe("close_popups", function(env)
  if env.OPENER ~= "claude_projects" then claude:set({ popup = { drawing = false } }) end
end)
claude:subscribe("mouse.exited.global", function()
  claude:set({ popup = { drawing = false } })
end)
