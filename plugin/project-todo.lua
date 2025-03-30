local Window = require "project-todo.window"
local App = require "project-todo.app"

---@class project-todo.vim.user_command
---@field name string
---@field args string
---@field fargs table
---@field nargs string
---@field bang boolean
---@field line1 number
---@field line2 number
---@field range number
---@field count number
---@field reg? string
---@field mods? string
---@field smods table


local app = App.get()
local win = Window:new(app.settings)

vim.api.nvim_create_user_command("ProjectTodo",
  ---@param args project-todo.vim.user_command
  function(args)
    local action = args.fargs[1] or "incomplete"
    if win:is_open() then
      -- This also runs the buf close aucmds
      win:close()
      return
    end

    win:open()
    app:register_window(win, action)
    app:populate_window(win, action == "complete")
  end, { nargs = "*" })
