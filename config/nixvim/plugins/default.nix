{pkgs, ...}: {
  conform-nvim = import ./conform.nix;

  lsp = import ./lsp.nix;

  cmp = {
    enable = true;
    settings = {
      mapping = {
        __raw = ''
          cmp.mapping.preset.insert({
            ['<C-n>'] = cmp.mapping(cmp.mapping.select_next_item()),
            ['<C-p>'] = cmp.mapping(cmp.mapping.select_prev_item()),
            ['<CR>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Insert, select = false })
          })
        '';
      };
      sources = [
        {
          name = "nvim_lsp";
        }
        {
          name = "path";
        }
        {
          name = "buffer";
        }
        {
          name = "luasnip";
        }
      ];
    };
  };
  # Completion engine
  cmp-nvim-lsp.enable = true;
  cmp-path.enable = true;
  cmp-buffer.enable = true;
  cmp_luasnip.enable = true;

  diffview = {
    enable = true;
  };

  telescope = {
    enable = true;
    extensions.live-grep-args = {
      enable = true;
      settings.auto_quoting = true;
    };

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
    updateFocusedFile.enable = true;
    actions = {
      openFile.resizeWindow = false;
    };
  };

  # settings are in extraconfig, not sure why it doesn't work for me here
  lualine = {
    enable = true;
  };

  bufferline = {
    enable = true;
  };

  auto-session = {
    enable = true;
    bypassSessionSaveFileTypes = [
      "nvim-tree"
    ];
    autoSave.enabled = true;
    autoRestore.enabled = true;
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

  tmux-navigator = {
    enable = true;
  };
}
