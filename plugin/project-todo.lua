local Window = require "project-todo.window"
local App = require "project-todo.app"

local app = App.get()
local win = Window:new(app.settings)

vim.api.nvim_create_user_command("ProjectTodo", function()
  if win:is_open() then
    -- This also runs the buf close aucmds
    win:close()
    return
  end

  win:open()
  app:populate_window(win)
  app:register_window(win)
end, { nargs = 0 })
