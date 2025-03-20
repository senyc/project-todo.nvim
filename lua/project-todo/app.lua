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

---@return project-todo.app
function App.get()
  if app then
    return app
  end
  local settings = Settings:new()
  local state = State:new(settings.save_dir)
  return App:new(settings, state)
end

---@param settings project-todo.settings
---@param state project-todo.state
---@return project-todo.app
function App:new(settings, state)
  app = setmetatable({
    settings = settings,
    ---TODO: update application to not require state, as it would make it difficult
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
  --TODO support git as the base instead of the user home directory
  ---@type string?
  local pwd = vim.uv.cwd()
  assert(pwd)
  -- Gets the base scope of the user's current project
  return Path.encode(pwd)
end

---@param window project-todo.window
function App:save_window_to_state(window)
  local lines = window:read_lines()
  local todos = Todo.from_lines(lines)
  local scope = self:get_scope()
  self.state:put(scope, todos)
end

---This will add the bufwrite auto command to keep the state in sync with the contents of the window
---@param window project-todo.window
function App:register_window(window)
  -- On resize re-center the window
  vim.api.nvim_create_autocmd({ "VimResized" }, {
    buffer = window.buf_id,
    callback = function()
      local win_opts = window:default_opts()
      vim.api.nvim_win_set_config(window.win_id, win_opts)
    end,
  })
  -- On close, save the buffer contents to state (filesystem)
  vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave" }, {
    buffer = window.buf_id,
    callback = function()
      self:save_window_to_state(window)
    end
  })
end

---This will populate the given window with state
---@param window project-todo.window
function App:populate_window(window)
  local scope = self:get_scope()
  local todos = self.state:get(scope)
  if todos then
    window:populate(todos)
  end
end

return App
