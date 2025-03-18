---@class project-todo.path
local Path = {}

---@param dir string
---@param fname string
---@return string
function Path.join(dir, fname)
  return dir .. "/" .. fname
end

return Path
