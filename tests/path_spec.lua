---@diagnostic disable: undefined-field
local Path = require "project-todo.path"

describe("Path.join", function()
  it("joins paths", function()
    local dir = "/etc/test"
    local fname = "value"
    assert.equals("/etc/test/value", Path.join(dir, fname))
  end)
end)

describe("Path.encode", function()
  describe("path encoding", function()
    it("should encode / to %2F", function()
      assert.equal("%2F", Path.encode("/"))
    end)

    it("should encode a basic path with subdirectories", function()
      local input = "Documents/MyFiles/test"
      local expected = "Documents%2FMyFiles%2Ftest"
      assert.equal(expected, Path.encode(input))
    end)

    it("should handle spaces in paths", function()
      local input = "My Documents/file/name"
      local expected = "My%20Documents%2Ffile%2Fname"
      assert.equal(expected, Path.encode(input))
    end)
    it("It should handle regular path names", function()
      local input = "/home/user/projects/myproject"
      local expected = "%2Fhome%2Fuser%2Fprojects%2Fmyproject"
      assert.equal(expected, Path.encode(input))
    end)
  end)
end)
