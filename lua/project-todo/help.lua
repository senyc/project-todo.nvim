
---@class project-todo.help
---@field buf_id integer?
local Help = {}
Help.__index = Help

--- Application singleton
---@type project-todo.help
local help

---@return project-todo.help
function Help.get()
  if help then
    return help
  end
  return Help._new()
end

---This should not be called directly please call Help.get() instead
---@return project-todo.help
function Help._new()
  help = setmetatable({
    buf_id = nil
  }, Help)
  return help
end

function Help.entries()
  return { "mc                      complete task" }
end

---Sets the buffer for the given window to use help buffer
--- this should include the teardown logic
---@param win_id integer window to set the help buffer to
---@param previous_buf_id integer current buffer being displayed to
function Help:display_help_in_window(win_id, previous_buf_id)
  self.buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(win_id, self.buf_id)
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = self.buf_id })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = self.buf_id })
  vim.api.nvim_set_option_value("filetype", "project-todo-help", { buf = self.buf_id })

  vim.api.nvim_buf_set_lines(self.buf_id, 0, -1, true, Help.entries())
  vim.api.nvim_set_option_value("modifiable", false, { buf = self.buf_id })

  vim.keymap.set("n", "g?", function()
    vim.api.nvim_win_set_buf(win_id, previous_buf_id)
  end, { buffer = self.buf_id, desc = "Toggle help" })
end

---Deletes the help buffer, should be called after setting the win_id content back to
--- todo buffer
function Help:teardown()
  vim.api.nvim_buf_delete(self.buf_id, { force = true })
end

return Help
