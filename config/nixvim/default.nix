{
  config,
  pkgs,
  ...
}: let
  extraConfig = builtins.readFile ./lua/extraConfig.lua;
  image-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "image.nvim";
    version = "1.5.1";
    nvimSkipModules = ["minimal-setup"];
    src = pkgs.fetchFromGitHub {
      owner = "3rd";
      repo = "image.nvim";
      rev = "v1.5.1";
      hash = "sha256-brDtVYD3O+7N2RdQPIx2+6P+faXafoJDUITy0z0cIuA=";
    };
  };
in {
  # neovim w. nixvim
  programs.nixvim = {
    enable = true;

    nixpkgs.pkgs = pkgs;

    globals.mapleader = " ";

    keymaps = import ./keymaps.nix;
    plugins = import ./plugins {inherit pkgs;};

    colorschemes.dracula.enable = true;

    # out the box options
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      showtabline = 2;
      directory = "${config.home.homeDirectory}/.local/share/nvim/swap//";
      undodir = "${config.home.homeDirectory}/.local/share/nvim/undo//";
      undofile = true;
    };

    # share clipboard with the os
    clipboard = {
      register = "unnamedplus";
    };

    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      nvim-lspconfig
      nvim-scrollbar
      luasnip
      image-nvim
    ];

    extraPackages = [pkgs.imagemagick pkgs.terraform];

    extraConfigLua = extraConfig;
  };
}
