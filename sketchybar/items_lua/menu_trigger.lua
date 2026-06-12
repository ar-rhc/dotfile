local icons = require("icons")

sbar.add("item", "menu_trigger", {
  icon = {
    string = icons.menu,
    font = { family = "SF Pro", style = "Regular", size = 16.0 },
  },
  label = { drawing = false },
  click_script = "osascript -e 'tell application \"BetterTouchTool\" to trigger_action \"{BTTIsPureAction: 1, BTTPredefinedActionType: 125, BTTPredefinedActionName: \\\"Show Menu Bar in Context Menu\\\"}\"'",
})
