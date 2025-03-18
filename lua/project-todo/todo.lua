---@class project-todo.todo
---@field title string
---@field type string
local Todo = {}
Todo.__index = Todo

---@param title string
---@param type? string
function Todo:new(title, type)
  return setmetatable({
    title = title,
    type = type or 'TODO'
  }, self)
end

---@return boolean
function Todo:is_complete()
  return self.type == 'DONE'
end

---@param lines string[]
---@return project-todo.todo
function Todo.from_lines(lines)
  ---@type project-todo.todo[]
  local todos = vim.tbl_map(function(line)
    local split = vim.split(vim.trim(line), ":")
    -- If no separator use default todo type
    if #split == 1 then
      return Todo:new(vim.trim(split[1]))
    end
    -- Re-join all items after the first separator
    ---@type string[]
    local title_items = {}
    table.move(split, 2, #split, 1, title_items)
    local title = table.concat(title_items, ":")
    local key, value = vim.trim(title), vim.trim(split[1])
    return Todo:new(value, key)
  end, lines)

  -- Filter out nil values
  return vim.tbl_filter(function(v) return v ~= nil end, todos)
end

return Todo
