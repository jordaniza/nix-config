{pkgs, ...}: {
  conform-nvim = import ./conform.nix;
  lsp = import ./lsp.nix;

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
  };

  lightline = {
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
  };
}
