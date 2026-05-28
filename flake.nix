{
  description = "Isolated NixVim environment for vim-nomisa development";

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

      nomisaPluginPath = self;

      nixvimModule = {
        extraPlugins = [
          pkgs.vimPlugins.plenary-nvim
          pkgs.vimPlugins.nvim-treesitter.withAllGrammars
        ];

        extraConfigLua = ''
          -- Add nomisa source to runtimepath (use env var set by shellHook)
          local nomisa_dev_path = vim.fn.getenv("NOMISA_DEV_PATH")
          if nomisa_dev_path and nomisa_dev_path ~= vim.NIL then
            vim.opt.runtimepath:prepend(nomisa_dev_path)
          else
            vim.opt.runtimepath:prepend("${nomisaPluginPath}")
          end

          vim.g.mapleader = " "

          -- Quick reload function for development
          _G.reload_nomisa = function()
            -- Clear cached lua modules
            for name, _ in pairs(package.loaded) do
              if name:match("^nomisa") then
                package.loaded[name] = nil
              end
            end
            -- Re-source vimscript files
            vim.cmd("runtime! plugin/nomisa.vim")
            vim.cmd("runtime! autoload/nomisa.vim")
            vim.cmd("runtime! autoload/nomisa_*.vim")
            local path = vim.fn.getenv("NOMISA_DEV_PATH") or "${nomisaPluginPath}"
            print("Nomisa reloaded from: " .. path)
          end

          vim.keymap.set("n", "<leader>rr", reload_nomisa, { desc = "Reload Nomisa" })

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
          echo "  Nomisa Development Environment"
          echo ""
          echo " Plugin source: $(pwd) (live reload enabled)"
          echo ""
          echo " Commands:"
          echo "   nvim                    - Start Neovim"
          echo ""
          echo " Keymaps (inside Neovim):"
          echo "   <Space>rr  - Reload nomisa (clears Lua cache)"
          echo "   <Space>rt  - Run plenary tests"
          echo ""

          export NOMISA_DEV_PATH="$(pwd)"

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
