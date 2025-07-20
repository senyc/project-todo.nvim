---@class project-todo.window
---@field opts vim.api.keyset.win_config
---@field buf_id integer
---@field win_id integer
---@field settings project-todo.settings
---@field showing_help boolean
local Window = {}
Window.__index = Window

--- Gets default win options to keep the screen centered
---@return vim.api.keyset.win_config
function Window:get_default_opts()
  return {
    style = "minimal",
    relative = "editor",
    width = self.settings.width,
    height = self.settings.height,
    border = "rounded",
    row = (vim.o.lines - self.settings.height) / 2,
    col = (vim.o.columns - self.settings.width) / 2,
  }
end

---@param settings project-todo.settings
---@param opts? vim.api.keyset.win_config
---@return project-todo.window
function Window:new(settings, opts)
  -- If the user passed on options we need to generate them after creating the initial table
  local win = setmetatable({
    buf_id = nil,
    win_id = nil,
    opts = opts,
    showing_help = false,
    settings = settings,
  }, self)
  if win.opts == nil then
    win.opts = win:get_default_opts()
  end
  return win
end

function Window:open()
  if self:is_open() then
    return
  end
  self.buf_id = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  local centered_opts = self.opts
  -- Always center the window on open
  centered_opts.row = (vim.o.lines - self.settings.height) / 2
  centered_opts.col = (vim.o.columns - self.settings.width) / 2

  self.win_id = vim.api.nvim_open_win(self.buf_id, true, centered_opts)

  -- We want the buffer to stay loaded if it is hidden (the help buffer)
  vim.api.nvim_set_option_value("bufhidden", "hide", { buf = self.buf_id })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf_id })
  vim.api.nvim_set_option_value("filetype", "project-todo", { buf = self.buf_id })

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
end

--- Releases win_id and buf_id without closing the buffer
--- this should be used after the window has been closed
function Window:release()
  if self:is_closed() then return end
  self.win_id = nil
  self.buf_id = nil
end

function Window:close()
  if self:is_closed() then return end

  vim.api.nvim_win_close(self.win_id, false)
  self:release()
end

---@return boolean
function Window:is_open()
  return self.win_id ~= nil
end

---@return boolean
function Window:is_closed()
  return not self:is_open()
end

---@param lines string[]
function Window:set_text(lines)
  ---@type string[]
  vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, true, lines)
end

--- Adds todo items to the given buffer
---@param todos project-todo.todo_data[]
function Window:populate_todos(todos)
  ---@param todo project-todo.todo_data
  ---@return string? line
  local function to_line(todo)
    return todo.type .. ": " .. todo.title
  end

  local lines = vim.tbl_map(to_line, todos)
  self:set_text(lines)
end

---Will read and return all current items in the window's buffer
---@return project-todo.todo
function Window:read_lines()
  return vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, true)
end

return Window
