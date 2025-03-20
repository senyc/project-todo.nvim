local Path = require("project-todo.path")
local mode = 438

---@class project-todo.state
---@field save_dir string
local State = {}
State.__index = State

---@param save_dir string
---@return project-todo.state
function State:new(save_dir)
  return setmetatable({
    save_dir = save_dir
  }, self)
end

---Creates the save directory if it does not exist
function State:ensure_exists()
  if vim.uv.fs_stat(self.save_dir) == nil then
    assert(vim.fn.mkdir(self.save_dir, "p"))
  end
end

---@param scope string the encoded scope (using Path.encode)
---@return project-todo.todo[]? data, string? error
function State:get(scope)
  local path       = Path.join(self.save_dir, scope)
  ---@type uv.fs_stat.result|nil
  local stat       = nil

  local fd, err, _ = vim.uv.fs_open(path, "r", mode)
  if not fd then
    return nil, err
  end

  stat, err, _ = vim.uv.fs_fstat(fd)
  if not stat then
    assert(vim.uv.fs_close(fd), string.format("could not close file: %s", path))
    return nil, err
  end

  ---@diagnostic disable-next-line: redefined-local
  local data, err = vim.uv.fs_read(fd, stat.size, 0)
  if not data then
    assert(vim.uv.fs_close(fd), string.format("could not close file: %s", path))
    return nil, err
  end

  assert(vim.uv.fs_close(fd), string.format("could not close file: %s", path))

  local ok, result = pcall(vim.json.decode, data)
  if not ok then
    return nil, result
  end

  return result, nil
end

---@param scope string encoded scope (using Path.encode)
---@param contents project-todo.todo[]
function State:put(scope, contents)
  local path = Path.join(self.save_dir, scope)
  local fd, err = vim.uv.fs_open(path, "w", mode)
  if not fd then
    return nil, err
  end
  local ok, result = pcall(vim.json.encode, contents)
  if not ok then
    assert(vim.uv.fs_close(fd), string.format("could not close file: %s", path))
    return nil, result
  end

  ---@diagnostic disable-next-line: redefined-local
  local _, err = vim.uv.fs_write(fd, result)
  if not err then
    return nil, err
  end
  assert(vim.uv.fs_close(fd))
end

---@param scope string
---@return string? error
function State:delete(scope)
  local path = Path.join(self.save_dir, scope)
  if vim.uv.fs_stat(self.save_dir) == nil then
    return
  end
  local ok, err = vim.uv.fs_unlink(path)
  if ok then
    return nil
  end
  return err
end

return State
