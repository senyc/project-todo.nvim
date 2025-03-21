local Settings = require("project-todo.settings")

describe("Settings", function()
  it("updates settings with a new save_dir", function()
    local settings = Settings:new()
    assert(settings.save_dir)
    settings:update { save_dir = "test" }
    assert(settings.save_dir == "test")
  end)

  it("Updates settings with width and height", function()
    local settings = Settings:new()
    assert(settings.width)
    assert(settings.height)
    settings:update { height = 5 }
    assert(settings.height == 5)
    settings:update { width = 4 }
    assert(settings.width == 4)
  end)
end)
