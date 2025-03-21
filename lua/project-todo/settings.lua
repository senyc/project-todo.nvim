---@class project-todo.settings
local Settings = {}

---@class project-todo.settings
---@field save_dir string
---@field width number
---@field height number
local DEFAULT_SETTINGS = {
  save_dir = vim.fn.stdpath("data") .. "/" .. "project-todo/",
  width = 60,
  height = 12
}

Settings.__index = function(tbl, key)
  return Settings[key] or tbl._inner[key]
end

---@return project-todo.settings
function Settings:new()
  return setmetatable({
    _inner = vim.deepcopy(DEFAULT_SETTINGS)
  }, self)
end

-- Update settings in-place
---@param opts? project-todo.settings
function Settings:update(opts)
  self._inner = vim.tbl_deep_extend("force", self._inner, opts or {})
end

return Settings
