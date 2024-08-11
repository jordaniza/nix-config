{pkgs, ...}: {
  conform-nvim = import ./conform.nix;
  lsp = import ./lsp.nix;

  telescope = {
    enable = true;
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

  treesitter = {
    enable = true;
    nixvimInjections = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };
}
