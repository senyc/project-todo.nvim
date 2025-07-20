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

local function project_todo_complete(arg_lead, cmd_line, cursor_pos)
  return { "incomplete", "complete", "count" }
end

vim.api.nvim_create_user_command("ProjectTodo",
  ---@param args project-todo.vim.user_command
  function(args)
    local action = args.fargs[1] or "incomplete"
    -- TODO: support the type of window in the actual window object so we can
    -- know whether the window type is complete or incomplete when user toggles
    -- so we can know how to save
    if action == "comment" then
      app:write_current_line_to_scope()
      return
    end
    if action == "count" then
      vim.print(app:get_total_tasks())
      return
    end
    if win:is_open() then
      -- This also runs the buf close aucmds
      win:close()
      return
    end

    win:open()
    app:register_window(win, action)
    app:populate_window(win, action == "complete")
  end, {
    nargs = "*",
    complete = project_todo_complete
  })
