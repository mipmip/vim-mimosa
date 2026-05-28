local config = require("nomisa.config")
local template = require("nomisa.template")

describe("template", function()
  local tmpdir

  before_each(function()
    tmpdir = vim.fn.tempname()
    vim.fn.mkdir(tmpdir .. "/svg", "p")
    vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/template.svg")
    config.setup({
      templates_path = tmpdir .. "/",
      extension_handlers = {},
    })
  end)

  after_each(function()
    vim.fn.delete(tmpdir, "rf")
  end)

  describe("get_extension_handler", function()
    it("returns handler for configured extension", function()
      config.setup({
        templates_path = tmpdir .. "/",
        extension_handlers = { svg = "fake-handler" },
      })
      assert.equals("fake-handler", template.get_extension_handler("svg"))
    end)

    it("returns nil for unconfigured extension", function()
      assert.is_nil(template.get_extension_handler("txt"))
    end)
  end)

  describe("get_template_file", function()
    it("returns template path when template exists", function()
      local result = template.get_template_file("svg")
      assert.is_not_nil(result)
      assert.truthy(result:match("template%.svg$"))
    end)

    it("returns first file when multiple templates exist", function()
      vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/another.svg")
      local result = template.get_template_file("svg")
      assert.is_not_nil(result)
    end)

    it("returns nil when no template exists", function()
      local result = template.get_template_file("webp")
      assert.is_nil(result)
    end)
  end)

  describe("open_template", function()
    local workdir

    before_each(function()
      workdir = vim.fn.tempname()
      vim.fn.mkdir(workdir, "p")
      vim.cmd("edit " .. workdir .. "/test.md")
    end)

    after_each(function()
      vim.fn.delete(workdir, "rf")
    end)

    it("creates file from template when file does not exist", function()
      template.open_template("images/diagram.svg")
      local file_path = workdir .. "/images/diagram.svg"
      assert.equals(1, vim.fn.filereadable(file_path))
    end)

    it("creates parent directories", function()
      template.open_template("deep/nested/dir/file.svg")
      assert.equals(1, vim.fn.isdirectory(workdir .. "/deep/nested/dir"))
    end)

    it("does not overwrite existing file", function()
      local file_path = workdir .. "/existing.svg"
      vim.fn.writefile({ "original" }, file_path)
      template.open_template("existing.svg")
      local content = vim.fn.readfile(file_path)
      assert.equals("original", content[1])
    end)

    it("does not create file when no template available", function()
      template.open_template("file.webp")
      assert.equals(0, vim.fn.filereadable(workdir .. "/file.webp"))
    end)
  end)
end)
