local icons = require("icons")

local trash = sbar.add("item", "trash", {
  position = "right",
  display = require("displays").lg,
  icon = { string = icons.trash, color = 0xffff9966 },
  label = { string = "", padding_left = 0 },
  padding_left = 3,
  padding_right = 3,
  update_freq = 30,
  updates = "on",
  drawing = false,
})

-- Use sketchybar CLI to set ourselves since sbar.exec callback has issues with osascript
trash:subscribe("routine", function()
  sbar.exec("count=$(osascript -l JavaScript -e 'Application(\"Finder\").trash.items.length' 2>/dev/null || echo 0); if [ \"$count\" -gt 0 ] 2>/dev/null; then sketchybar --set trash drawing=on label=\"$count\"; else sketchybar --set trash drawing=off; fi &")
end)

trash:subscribe("mouse.clicked", function(env)
  if env.MODIFIER ~= "none" and env.MODIFIER ~= "" then
    sbar.exec([[osascript -l JavaScript -e 'Application("Finder").trash.open()' &]])
  else
    sbar.exec([[osascript -l JavaScript -e '
      var app = Application.currentApplication();
      app.includeStandardAdditions = true;
      app.displayDialog("Are you sure you want to permanently erase the items in the Trash?\n\nYou cannot undo this action.", {
        buttons: ["Cancel", "Empty Trash"],
        defaultButton: 2,
        withIcon: Path("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FullTrashIcon.icns")
      });' 2>/dev/null && osascript -l JavaScript -e 'var f=Application("Finder"); if(f.trash.items.length>0){f.empty()}' && sketchybar --set trash drawing=off &]])
  end
end)

-- Initial check
sbar.exec("count=$(osascript -l JavaScript -e 'Application(\"Finder\").trash.items.length' 2>/dev/null || echo 0); if [ \"$count\" -gt 0 ] 2>/dev/null; then sketchybar --set trash drawing=on label=\"$count\"; else sketchybar --set trash drawing=off; fi &")
