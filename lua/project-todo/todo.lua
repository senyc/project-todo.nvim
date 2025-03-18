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

---@param s string?
local function is_empty(s)
  return s == "" or s == nil
end

---@param line string
---@return project-todo.todo? todo
function Todo.from_line(line)
  -- If empty line don't return a todo item
  if #vim.trim(line) == 0 then
    return nil
  end

  local split = vim.split(vim.trim(line), ":")

  -- If no separator use default todo type
  if #split == 1 then
    return Todo:new(vim.trim(split[1]))
  end

  ---@type string[]
  local title_items = table.move(split, 2, #split, 1, {})
  -- Will re-add the : as it is part of the user's title text
  local title, type = vim.trim(table.concat(title_items, ":")), vim.trim(split[1])

  if is_empty(type) then
    return Todo:new(title)
  end
  return Todo:new(title, type)
end

---@param lines string[]
---@return project-todo.todo
function Todo.from_lines(lines)
  ---@type project-todo.todo[]
  local todos = vim.tbl_map(function(line)
    return Todo.from_line(line)
  end, lines)

  -- Filter out nil values
  return vim.tbl_filter(function(v) return v ~= nil end, todos)
end

return Todo
