{
  description = "Isolated NixVim environment for vim-mimosa development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixvim, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      mimosaPluginPath = self;

      nixvimModule = {
        extraPlugins = [
          pkgs.vimPlugins.plenary-nvim
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];

        extraConfigLua = ''
          -- Add mimosa source to runtimepath (use env var set by shellHook)
          local mimosa_dev_path = vim.fn.getenv("MIMOSA_DEV_PATH")
          if mimosa_dev_path and mimosa_dev_path ~= vim.NIL then
            vim.opt.runtimepath:prepend(mimosa_dev_path)
          else
            vim.opt.runtimepath:prepend("${mimosaPluginPath}")
          end

          vim.g.mapleader = " "

          -- Quick reload function for development
          _G.reload_mimosa = function()
            -- Clear cached lua modules
            for name, _ in pairs(package.loaded) do
              if name:match("^mimosa") then
                package.loaded[name] = nil
              end
            end
            -- Re-source vimscript files
            vim.cmd("runtime! plugin/mimosa.vim")
            vim.cmd("runtime! autoload/mimosa.vim")
            vim.cmd("runtime! autoload/mimosa_*.vim")
            local path = vim.fn.getenv("MIMOSA_DEV_PATH") or "${mimosaPluginPath}"
            print("Mimosa reloaded from: " .. path)
          end

          vim.keymap.set("n", "<leader>rr", reload_mimosa, { desc = "Reload Mimosa" })

          -- Run plenary tests
          vim.keymap.set("n", "<leader>rt", function()
            vim.cmd("PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}")
          end, { desc = "Run tests" })
        '';

        opts = {
          number = true;
          relativenumber = true;
          expandtab = true;
          shiftwidth = 2;
          tabstop = 2;
          signcolumn = "yes";
          termguicolors = true;
        };

        colorschemes.gruvbox.enable = true;

        plugins = {
          lualine.enable = true;
          web-devicons.enable = true;
          treesitter.enable = true;

          lsp = {
            enable = true;
            servers = {
              lua_ls = {
                enable = true;
                settings = {
                  Lua = {
                    diagnostics = {
                      globals = [ "vim" "describe" "it" "before_each" "after_each" ];
                    };
                    workspace = {
                      library = [
                        "\${3rd}/luv/library"
                      ];
                      checkThirdParty = false;
                    };
                  };
                };
              };
            };
          };
        };
      };

      nvim = nixvim.legacyPackages.${system}.makeNixvimWithModule {
        inherit pkgs;
        module = nixvimModule;
      };

    in
    {
      packages.${system} = {
        default = nvim;
        neovim = nvim;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          nvim
          pkgs.lua-language-server
          pkgs.stylua
        ];

        shellHook = ''
          echo ""
          echo "  Mimosa Development Environment"
          echo ""
          echo " Plugin source: $(pwd) (live reload enabled)"
          echo ""
          echo " Commands:"
          echo "   nvim                    - Start Neovim"
          echo ""
          echo " Keymaps (inside Neovim):"
          echo "   <Space>rr  - Reload mimosa (clears Lua cache)"
          echo "   <Space>rt  - Run plenary tests"
          echo ""

          export MIMOSA_DEV_PATH="$(pwd)"

          export XDG_CONFIG_HOME="$(pwd)/.dev/config"
          export XDG_DATA_HOME="$(pwd)/.dev/share"
          export XDG_STATE_HOME="$(pwd)/.dev/state"
          export XDG_CACHE_HOME="$(pwd)/.dev/cache"

          mkdir -p "$XDG_CONFIG_HOME" "$XDG_DATA_HOME" "$XDG_STATE_HOME" "$XDG_CACHE_HOME"
        '';
      };

      apps.${system}.default = {
        type = "app";
        program = "${nvim}/bin/nvim";
      };
    };
}
