local State = require('project-todo.state')
local Settings = require('project-todo.settings')
local Todo = require("project-todo.todo")

local save_dir = "./tmp"

describe("State", function()
  local settings

  before_each(function()
    settings = Settings:new()
    settings:update({ save_dir = save_dir })
  end)

  it("Manages base state location", function()
    local state = State:new(settings.save_dir)
    state:ensure_exists()
    assert(vim.uv.fs_stat(settings.save_dir))
  end)

  it("Puts data into state location with scope", function()
    local state    = State:new(settings.save_dir)
    local todo     = Todo:new("do stuff")
    local todo_two = Todo:new("do stuff two")
    local _, err   = state:put("test", { todo, todo_two })
    assert(err == nil, err)
  end)

  it("Gets data from state with given scope", function()
    local state    = State:new(settings.save_dir)
    local todo     = Todo:new("do stuff")
    local todo_two = Todo:new("do stuff two")
    local _, err   = state:put("test", { todo, todo_two })
    assert(err == nil, err)
    local data = state:get("test")
    assert(data and data[1].title == 'do stuff')
    assert(data and data[2].title == 'do stuff two')
  end)

  it("Deletes state items", function()
    local state  = State:new(settings.save_dir)
    local todo   = Todo:new("do stuff")
    local _, err = state:put("test", { todo })
    assert(err == nil, err)
    assert(state:delete("test") == nil)
  end)
end)
