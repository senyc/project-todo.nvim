---@class project-todo.window
---@field opts vim.api.keyset.win_config
---@field buf_id integer
---@field win_id integer
---@field settings project-todo.settings
local Window = {}
Window.__index = Window

---@return vim.api.keyset.win_config
function Window:default_opts()
  local gheight = vim.api.nvim_list_uis()[1].height
  local gwidth = vim.api.nvim_list_uis()[1].width
  local width = 60
  local height = 12
  ---@type vim.api.keyset.win_config
  return {
    relative = "editor",
    width = width,
    height = height,
    row = (gheight - height) * 0.5,
    col = (gwidth - width) * 0.5,
    border = 'single',
    style = 'minimal'
  }
end

---@param settings project-todo.settings
---@param opts? vim.api.keyset.win_config
---@return project-todo.window
function Window:new(settings, opts)
  return setmetatable({
    opts = opts or self:default_opts(),
    buf_id = nil,
    settings = settings,
    win_id = nil,
  }, self)
end

function Window:open()
  self.buf_id = vim.api.nvim_create_buf(false, true) -- No file, scratch buffer
  self.win_id = vim.api.nvim_open_win(self.buf_id, true, self.opts)

  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = self.buf_id })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf_id })
  vim.api.nvim_set_option_value("filetype", "project-todo", { buf = self.buf_id })

  vim.api.nvim_set_option_value("modifiable", true, { buf = self.buf_id })
end

---@param entries project-todo.todo[]
function Window:populate(entries)
  ---@param entry project-todo.todo
  ---@return string line
  local function to_line(entry)
    return entry.type .. ': ' .. entry.title
  end

  ---@type string[]
  vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, true, vim.tbl_map(to_line, entries))
end

---Will read and return all current items in the window's buffer
---@return project-todo.todo
function Window:read_lines()
  return vim.api.nvim_buf_get_lines(self.buf_id, 0, -1, true)
end

return Window
