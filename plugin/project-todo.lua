local Window = require "project-todo.window"
local Settings = require "project-todo.settings"
local State = require "project-todo.state"
local App = require "project-todo.app"

vim.api.nvim_create_user_command("ProjectTodo", function()
  local app = App.get()
  local win = Window:new(app.settings)
  win:open()
  app:populate_window(win)
  app:register_window(win)
end, { nargs = 0 })
