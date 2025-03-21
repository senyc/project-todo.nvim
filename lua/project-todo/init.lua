local ProjectTodo = require "project-todo.app"
local M = {}

---@param settings project-todo.settings
function M.setup(settings)
  ProjectTodo.get():update(settings)
end

return M
