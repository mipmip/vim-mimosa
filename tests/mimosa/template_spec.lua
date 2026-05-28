local config = require("mimosa.config")
local template = require("mimosa.template")

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

    it("falls back to default_handler for unconfigured extension", function()
      assert.equals(config.values.default_handler, template.get_extension_handler("txt"))
    end)

    it("uses explicit handler over default_handler", function()
      config.setup({
        templates_path = tmpdir .. "/",
        extension_handlers = { svg = "inkscape" },
      })
      assert.equals("inkscape", template.get_extension_handler("svg"))
    end)

    it("respects user-overridden default_handler", function()
      config.setup({
        templates_path = tmpdir .. "/",
        extension_handlers = {},
        default_handler = "my-opener",
      })
      assert.equals("my-opener", template.get_extension_handler("docx"))
    end)
  end)

  describe("get_template_file", function()
    it("returns single template via callback", function()
      local result
      template.get_template_file("svg", function(f) result = f end)
      assert.is_not_nil(result)
      assert.truthy(result:match("template%.svg$"))
    end)

    it("returns nil without warning for unconfigured extension", function()
      local warned = false
      local orig_notify = vim.notify
      vim.notify = function() warned = true end
      local result
      template.get_template_file("webp", function(f) result = f end)
      vim.notify = orig_notify
      assert.is_nil(result)
      assert.is_false(warned)
    end)

    it("returns nil with warning for configured extension missing template", function()
      config.setup({
        templates_path = tmpdir .. "/",
        extension_handlers = { webp = "gimp" },
      })
      local warned = false
      local orig_notify = vim.notify
      vim.notify = function() warned = true end
      local result
      template.get_template_file("webp", function(f) result = f end)
      vim.notify = orig_notify
      assert.is_nil(result)
      assert.is_true(warned)
    end)

    it("calls vim.ui.select when multiple templates exist", function()
      vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/another.svg")
      local select_called = false
      local orig_select = vim.ui.select
      vim.ui.select = function(items, opts, on_choice)
        select_called = true
        assert.equals(2, #items)
        on_choice(items[1], 1)
      end
      local result
      template.get_template_file("svg", function(f) result = f end)
      vim.ui.select = orig_select
      assert.is_true(select_called)
      assert.is_not_nil(result)
    end)

    it("returns nil when user cancels picker", function()
      vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/another.svg")
      local orig_select = vim.ui.select
      vim.ui.select = function(_, _, on_choice)
        on_choice(nil, nil)
      end
      local result = "not-nil"
      template.get_template_file("svg", function(f) result = f end)
      vim.ui.select = orig_select
      assert.is_nil(result)
    end)

    it("shows filenames in picker, not full paths", function()
      vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/another.svg")
      local shown_items
      local orig_select = vim.ui.select
      vim.ui.select = function(items, _, on_choice)
        shown_items = items
        on_choice(items[1], 1)
      end
      template.get_template_file("svg", function() end)
      vim.ui.select = orig_select
      for _, name in ipairs(shown_items) do
        assert.is_falsy(name:find("/"))
      end
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

    it("does not create file when user cancels template picker", function()
      vim.fn.writefile({ "<svg></svg>" }, tmpdir .. "/svg/another.svg")
      local orig_select = vim.ui.select
      vim.ui.select = function(_, _, on_choice)
        on_choice(nil, nil)
      end
      template.open_template("new-diagram.svg")
      vim.ui.select = orig_select
      assert.equals(0, vim.fn.filereadable(workdir .. "/new-diagram.svg"))
    end)
  end)
end)
