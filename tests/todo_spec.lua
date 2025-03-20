---@diagnostic disable: undefined-field
local Todo = require "project-todo.todo"

describe("Todo management", function()
  local todo

  before_each(function()
    todo = Todo:new("Test task", "TODO")
  end)

  describe("#new", function()
    it("should create a todo with title and type", function()
      assert.is_not_nil(todo)
      assert.equals(todo.title, "Test task")
      assert.equals(todo.type, "TODO")
    end)

    it("should default to TODO type if not provided", function()
      local new_todo = Todo:new("New task")
      assert.equals(new_todo.type, "TODO")
    end)
  end)

  describe("#is_complete", function()
    it("should return true for DONE type", function()
      todo = Todo:new("Complete tasks", "DONE")
      assert.is_true(todo:is_complete())
    end)

    it("should return false for TODO type", function()
      assert.is_false(todo:is_complete())
    end)
  end)
end)

describe("Todo parsing", function()
  describe("#from_line", function()
    it("should parse a line with no colon as title only", function()
      local todo = Todo.from_line("Complete tasks")
      assert(todo)
      assert.equals(todo.title, "Complete tasks")
      assert.equals(todo.type, "TODO")
    end)

    it("should parse a line with type and title separated by colon", function()
      local todo = Todo.from_line("DONE: Read book")
      assert(todo)
      assert.equals(todo.title, "Read book")
      assert.equals(todo.type, "DONE")
    end)

    it("should handle lines with only colons", function()
      local todo = Todo.from_line(":TODO")
      assert(todo)
      assert.equals("TODO", todo.type)
      assert.equals("TODO", todo.title)
    end)

    it("should handle lines with empty strings", function()
      local result = Todo.from_line("")
      assert.is_nil(result)
    end)
  end)

  describe("#from_lines", function()
    it("should parse multiple lines and filter out nil values", function()
      local lines = {
        "Complete tasks",
        "TODO: Read book",
      }
      local todos = Todo.from_lines(lines)

      assert.equals(#todos, 2)
      assert.equals("Complete tasks", todos[1].title)
      assert.equals("Read book", todos[2].title)
    end)
  end)
end)
