---@class project-todo.settings
local Settings = {}


---@class project-todo.settings
local DEFAULT_SETTINGS = {
  save_dir = vim.fn.stdpath("data") .. "/" .. "project-todo/",
}

Settings.__index = function(tbl, key)
  return Settings[key] or tbl.inner[key]
end

---@return project-todo.settings
function Settings:new()
  return setmetatable({
    inner = vim.deepcopy(DEFAULT_SETTINGS)
  }, self)
end

-- Update settings in-place
---@param opts? project-todo.settings
function Settings:update(opts)
  self.inner = vim.tbl_deep_extend("force", self.inner, opts or {})
end

return Settings
