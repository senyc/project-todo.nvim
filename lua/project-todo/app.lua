local Todo = require "project-todo.todo"
local Settings = require "project-todo.settings"
local Path = require "project-todo.path"
local State = require "project-todo.state"

---@class project-todo.app
---@field settings project-todo.settings
---@field state project-todo.state
local App = {}
App.__index = App

--- Application singleton
---@type project-todo.app
local app

---Returns application singleton or creates one if one doesn't already exist
---@return project-todo.app
function App.get()
  if app then
    return app
  end
  local settings = Settings:new()
  local state = State:new(settings.save_dir)
  state:ensure_exists()
  return App:_new(settings, state)
end

---This should not be called directly, please call App.get() instead
---@param settings project-todo.settings
---@param state project-todo.state
---@return project-todo.app
function App:_new(settings, state)
  app = setmetatable({
    settings = settings,
    --- to support multiple scopes at once
    state = state
  }, self)
  return app
end

function App:init()
  self.state:ensure_exists()
end

--- Sanitizes the user's current directory into a sanitized string
---@return string
function App:get_scope()
  ---@type string?
  local pwd = vim.uv.cwd()
  assert(pwd)
  return Path.encode(pwd)
end

--- Sanitizes the user's current directory into a sanitized string
---@return string
function App:get_completed_scope()
  ---@type string?
  local pwd = vim.uv.cwd()
  assert(pwd)
  return Path.encode("complete" .. pwd)
end

--- Will add any complete types to "done" state, and replace all
--- incomplete todos with window contents
---@param window project-todo.window
function App:save_window_to_state(window)
  local lines = window:read_lines()
  local todos = Todo.from_lines(lines)
  local incomplete_todos = vim.tbl_filter(function(todo) return todo.type ~= "DONE" end, todos)
  local complete_todos = vim.tbl_filter(function(todo) return todo.type == "DONE" end, todos)
  -- Replaces incomplete items since the buffer is displaying all of them
  self.state:put(self:get_scope(), incomplete_todos)
  -- Appends completed items (so we don't replace existing completed items
  if #complete_todos > 0 then
    self.state:add(self:get_completed_scope(), complete_todos)
  end
end

--- Will add any non-complete types to state, and replace all completed tasks
--- with window contents
---@param window project-todo.window
function App:save_complete_window_to_state(window)
  local lines = window:read_lines()
  local todos = Todo.from_lines(lines)
  local incomplete_todos = vim.tbl_filter(function(todo) return todo.type ~= "DONE" end, todos)
  local complete_todos = vim.tbl_filter(function(todo) return todo.type == "DONE" end, todos)

  -- Replaces complete items since the buffer is displaying all of them
  self.state:put(self:get_completed_scope(), complete_todos)

  -- Appends incompleted items (so we don't replace existing incomplete items
  if #incomplete_todos > 0 then
    self.state:add(self:get_scope(), incomplete_todos)
  end
end

---This will add the bufwrite auto command to keep the state in sync with the contents of the window
---@param window project-todo.window
---@param type "complete" | "incomplete"
function App:register_window(window, type)
  -- On resize re-center the window
  vim.api.nvim_create_autocmd({ "VimResized" }, {
    buffer = window.buf_id,
    callback = function()
      local win_opts = window:default_opts(self.settings)
      vim.api.nvim_win_set_config(window.win_id, win_opts)
    end,
  })

  -- On close, save the buffer contents to state
  vim.api.nvim_create_autocmd({ "BufLeave" }, {
    buffer = window.buf_id,
    callback = function()
      if type == "incomplete" then
        self:save_window_to_state(window)
      else
        self:save_complete_window_to_state(window)
      end
      window:release()
    end
  })
end

---This will populate the given window with state
---@param window project-todo.window
---@param show_complete? boolean
function App:populate_window(window, show_complete)
  if show_complete then
    local complete_todos = self.state:get(self:get_completed_scope())
    if complete_todos then
      window:populate_todos(complete_todos)
    end
  else
    local incomplete_todos = self.state:get(self:get_scope())
    if incomplete_todos then
      window:populate_todos(incomplete_todos)
    end
  end
end

---Updates the application configuration in-place
---@param opts project-todo.settings
function App:update(opts)
  self.settings:update(opts)
end

--- This will convert the line the user is on to a todo item and add to state
--- then it will delete the current line (without saving the buffer)
---@return string? error
function App:write_current_line_to_scope()
  local curr_line = vim.api.nvim_get_current_line()
  local todo_line = Todo.sanitize_todo_line(curr_line)

  if not todo_line then return "unable to get todo line" end

  local todo = Todo.from_line(todo_line)
  if not todo then
    return "no todo found"
  end

  if todo:is_complete() then
    self.state:add(self:get_completed_scope(), { todo })
  else
    self.state:add(self:get_scope(), { todo })
  end
  vim.api.nvim_del_current_line()
end

return App
