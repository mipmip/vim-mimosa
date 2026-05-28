local parse = require("nomisa.parse")

describe("parse", function()
  describe("extract_path_from_line", function()
    it("extracts path from markdown image link", function()
      assert.equals("images/diagram.svg", parse.extract_path_from_line("![alt text](images/diagram.svg)"))
    end)

    it("extracts path with empty alt text", function()
      assert.equals("images/diagram.svg", parse.extract_path_from_line("![](images/diagram.svg)"))
    end)

    it("extracts content from bare parentheses", function()
      assert.equals("with parens", parse.extract_path_from_line("some text (with parens)"))
    end)

    it("returns nil when no parentheses", function()
      assert.is_nil(parse.extract_path_from_line("just plain text"))
    end)

    it("returns nil for empty string", function()
      assert.is_nil(parse.extract_path_from_line(""))
    end)

    it("handles path with spaces", function()
      assert.equals("my images/diagram.svg", parse.extract_path_from_line("![](my images/diagram.svg)"))
    end)

    it("uses first pair of parentheses", function()
      assert.equals("first", parse.extract_path_from_line("text (first) and (second)"))
    end)
  end)
end)
