local parse = require("mimosa.parse")

describe("parse", function()
  describe("extract_markdown_paths", function()
    it("extracts path from standard markdown image link", function()
      local matches = parse.extract_markdown_paths("![alt text](images/diagram.svg)")
      assert.equals(1, #matches)
      assert.equals("images/diagram.svg", matches[1].path)
      assert.equals("markdown", matches[1].type)
    end)

    it("extracts path with empty alt text", function()
      local matches = parse.extract_markdown_paths("![](images/diagram.svg)")
      assert.equals(1, #matches)
      assert.equals("images/diagram.svg", matches[1].path)
    end)

    it("extracts path from markdown link (not image)", function()
      local matches = parse.extract_markdown_paths("[click here](docs/guide.pdf)")
      assert.equals(1, #matches)
      assert.equals("docs/guide.pdf", matches[1].path)
    end)

    it("handles path with spaces", function()
      local matches = parse.extract_markdown_paths("![](my images/diagram.svg)")
      assert.equals(1, #matches)
      assert.equals("my images/diagram.svg", matches[1].path)
    end)

    it("does not match bare parentheses without ] prefix", function()
      local matches = parse.extract_markdown_paths("some text (with parens)")
      assert.equals(0, #matches)
    end)

    it("finds multiple matches on one line", function()
      local matches = parse.extract_markdown_paths("![](arch.svg) and ![](team.jpg)")
      assert.equals(2, #matches)
      assert.equals("arch.svg", matches[1].path)
      assert.equals("team.jpg", matches[2].path)
    end)

    it("returns empty for no matches", function()
      local matches = parse.extract_markdown_paths("just plain text")
      assert.equals(0, #matches)
    end)
  end)

  describe("extract_html_img_paths", function()
    it("extracts double-quoted src", function()
      local matches = parse.extract_html_img_paths('<img src="image.png">')
      assert.equals(1, #matches)
      assert.equals("image.png", matches[1].path)
      assert.equals("html_img", matches[1].type)
    end)

    it("extracts single-quoted src", function()
      local matches = parse.extract_html_img_paths("<img src='image.png'>")
      assert.equals(1, #matches)
      assert.equals("image.png", matches[1].path)
    end)

    it("extracts unquoted src", function()
      local matches = parse.extract_html_img_paths("<img src=image.png>")
      assert.equals(1, #matches)
      assert.equals("image.png", matches[1].path)
    end)

    it("extracts src when not first attribute", function()
      local matches = parse.extract_html_img_paths('<img alt="photo" src="team.jpg" width="100">')
      assert.equals(1, #matches)
      assert.equals("team.jpg", matches[1].path)
    end)

    it("extracts from self-closing tag", function()
      local matches = parse.extract_html_img_paths('<img src="image.png" />')
      assert.equals(1, #matches)
      assert.equals("image.png", matches[1].path)
    end)

    it("returns empty when no img tag", function()
      local matches = parse.extract_html_img_paths("just plain text")
      assert.equals(0, #matches)
    end)
  end)

  describe("extract_at_paths", function()
    it("extracts absolute path", function()
      local matches = parse.extract_at_paths("see @/home/pim/file.png for details")
      assert.equals(1, #matches)
      assert.equals("/home/pim/file.png", matches[1].path)
      assert.equals("at_ref", matches[1].type)
    end)

    it("extracts relative path", function()
      local matches = parse.extract_at_paths("check @images/diagram.svg")
      assert.equals(1, #matches)
      assert.equals("images/diagram.svg", matches[1].path)
    end)

    it("extracts bare filename", function()
      local matches = parse.extract_at_paths("open @file.png")
      assert.equals(1, #matches)
      assert.equals("file.png", matches[1].path)
    end)

    it("strips trailing period", function()
      local matches = parse.extract_at_paths("see @file.png.")
      assert.equals(1, #matches)
      assert.equals("file.png", matches[1].path)
    end)

    it("strips trailing comma", function()
      local matches = parse.extract_at_paths("@image.svg, and more")
      assert.equals(1, #matches)
      assert.equals("image.svg", matches[1].path)
    end)

    it("extracts at end of line", function()
      local matches = parse.extract_at_paths("reference @docs/img.png")
      assert.equals(1, #matches)
      assert.equals("docs/img.png", matches[1].path)
    end)

    it("returns empty when no @ reference", function()
      local matches = parse.extract_at_paths("just plain text")
      assert.equals(0, #matches)
    end)
  end)

  describe("pick_closest", function()
    local matches = {
      { path = "arch.svg", start = 5, fin = 12, type = "markdown" },
      { path = "team.jpg", start = 25, fin = 32, type = "markdown" },
    }

    it("picks match closest to cursor (near second)", function()
      local m = parse.pick_closest(matches, 30)
      assert.equals("team.jpg", m.path)
    end)

    it("picks match closest to cursor (near first)", function()
      local m = parse.pick_closest(matches, 5)
      assert.equals("arch.svg", m.path)
    end)

    it("picks match when cursor is inside", function()
      local m = parse.pick_closest(matches, 8)
      assert.equals("arch.svg", m.path)
    end)

    it("picks first match on tiebreak", function()
      -- Equidistant: col 18 is 6 from fin=12 and 7 from start=25
      -- col 19 is 7 from fin=12 and 6 from start=25 → second wins
      -- col 18.5 doesn't exist, so test col 18 (first wins) and col 19 (second wins)
      local m = parse.pick_closest(matches, 18)
      assert.equals("arch.svg", m.path)
    end)

    it("picks first match when col is nil", function()
      local m = parse.pick_closest(matches, nil)
      assert.equals("arch.svg", m.path)
    end)

    it("returns nil for empty matches", function()
      assert.is_nil(parse.pick_closest({}, 5))
    end)
  end)

  describe("validation", function()
    it("rejects @ at start of markdown path", function()
      local path, err = parse.extract_path_from_line("![img](@some/path.png)")
      assert.is_nil(path)
      assert.is_not_nil(err)
      assert.is_truthy(err:find("not supported"))
    end)

    it("rejects @ in markdown link", function()
      local path, err = parse.extract_path_from_line("[link](@some/file.pdf)")
      assert.is_nil(path)
      assert.is_not_nil(err)
      assert.is_truthy(err:find("not supported"))
    end)

    it("does not reject normal markdown paths", function()
      local path, err = parse.extract_path_from_line("![img](some/path.png)")
      assert.equals("some/path.png", path)
      assert.is_nil(err)
    end)
  end)

  describe("extract_path_from_line (integration)", function()
    it("extracts path from markdown image link", function()
      assert.equals("images/diagram.svg", parse.extract_path_from_line("![alt text](images/diagram.svg)"))
    end)

    it("extracts path with empty alt text", function()
      assert.equals("images/diagram.svg", parse.extract_path_from_line("![](images/diagram.svg)"))
    end)

    it("returns nil for bare parentheses (breaking change)", function()
      assert.is_nil(parse.extract_path_from_line("some text (with parens)"))
    end)

    it("returns nil when no matches", function()
      assert.is_nil(parse.extract_path_from_line("just plain text"))
    end)

    it("returns nil for empty string", function()
      assert.is_nil(parse.extract_path_from_line(""))
    end)

    it("handles path with spaces", function()
      assert.equals("my images/diagram.svg", parse.extract_path_from_line("![](my images/diagram.svg)"))
    end)

    it("picks closest to cursor with multiple markdown matches", function()
      local line = "![](arch.svg) and ![](team.jpg)"
      -- "arch.svg" starts at col 5, "team.jpg" starts at col 23
      assert.equals("arch.svg", parse.extract_path_from_line(line, 1))
      assert.equals("team.jpg", parse.extract_path_from_line(line, 30))
    end)

    it("extracts from HTML img tag", function()
      assert.equals("image.png", parse.extract_path_from_line('<img src="image.png">'))
    end)

    it("extracts from @filepath", function()
      assert.equals("images/diagram.svg", parse.extract_path_from_line("see @images/diagram.svg for details"))
    end)

    it("returns first match when col is nil", function()
      local path = parse.extract_path_from_line("![](first.svg) and ![](second.jpg)")
      assert.equals("first.svg", path)
    end)
  end)
end)
