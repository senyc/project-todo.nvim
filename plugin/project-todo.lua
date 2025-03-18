local Window = require "project-todo.window"
local Settings = require "project-todo.settings"
local State = require "project-todo.state"
local App = require "project-todo.app"

vim.api.nvim_create_user_command("ProjectTodo", function()
  local settings = Settings:new()
  local win = Window:new(settings)
  local state = State:new(settings.save_dir)
  state:ensure_exists()
  local app = App:new(settings, state)
  win:open()
  app:populate_window(win)
  app:register_window(win)
end, { nargs = 0 })
