---@class project-todo.path
local Path = {}

---@param dir string
---@param fname string
---@return string
function Path.join(dir, fname)
  return dir .. "/" .. fname
end

---@param plain_string string regular path string to encode
function Path.encode(plain_string)
  local encoded = string.gsub(plain_string, "([^%w])", function(match)
    return string.upper(string.format("%%%02x", string.byte(match)))
  end)
  return encoded
end

return Path
