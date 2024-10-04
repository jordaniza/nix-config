{pkgs, ...}: {
  conform-nvim = import ./conform.nix;
  lsp = import ./lsp.nix;

  cmp = {
    enable = true;
    settings = {
      sources = [
        {
          name = "nvim_lsp";
        }
        {
          name = "luasnip";
        }
        {
          name = "path";
        }
        {
          name = "buffer";
        }
      ];
    };
  };

  cmp-nvim-lsp = {
    enable = true;
  };
  cmp-buffer = {
    enable = true;
  };
  cmp-path = {
    enable = true;
  };
  cmp-cmdline = {
    enable = true;
  };
  luasnip = {
    enable = true;
  };

  telescope = {
    enable = true;
    settings = {
      defaults = {
        file_ignore_patterns = [
          "^.git/"
          "^.mypy_cache/"
          "^__pycache__/"
          "^output/"
          "^data/"
          "%.ipynb"
          "^node_modules/"
        ];
      };
    };
  };
  harpoon = {
    enable = true;
  };

  nvim-tree = {
    enable = true;
    git = {
      enable = true;
      ignore = false;
    };
    filters = {
      dotfiles = false;
    };
  };

  # settings are in extraconfig, not sure why it doesn't work for me here
  lualine = {
    enable = true;
  };

  bufferline = {
    enable = true;
  };

  lsp-lines = {
    enable = true;
  };

  auto-save = {
    enable = true;
  };

  comment = {
    enable = true;
  };

  treesitter = {
    enable = true;
    nixvimInjections = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };

  copilot-vim = {
    enable = true;
    settings = {
      filetypes = {
        markdown = false;
      };
    };
  };
}
