local Settings = require('project-todo.settings')

describe("Settings", function()
  it("updates settings with a new save_dir", function()
    local settings = Settings:new()
    assert(settings.save_dir)
    print(settings.save_dir)
    settings:update { save_dir = 'test' }
    assert(settings.save_dir == 'test')
  end)
end)
