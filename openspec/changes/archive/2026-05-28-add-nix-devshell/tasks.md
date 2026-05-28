# Tasks: Add Nix Devshell

## Tasks

- [x] Create `flake.nix` with NixVim module, devShell, and app output
  - NixVim module: extraPlugins (plenary, treesitter), extraConfigLua (rtp, reload, test keymap), opts, colorscheme, plugins (lualine, devicons, treesitter, lua_ls)
  - devShell: nvim + lua-language-server + stylua, XDG isolation, NOMISA_DEV_PATH, shell banner
  - App output: `nix run` launches the configured nvim
- [x] Add `.dev/` to `.gitignore`
- [x] Verify: `nix develop` enters shell, `nvim` launches with plugin loaded, `<Space>rr` reloads, plenary is available
