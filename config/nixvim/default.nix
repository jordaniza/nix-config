{
  config,
  pkgs,
  ...
}: let
  extraConfig = builtins.readFile ./lua/extraConfig.lua;
in {
  # neovim w. nixvim
  programs.nixvim = {
    enable = true;

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
    ];

    extraConfigLua = extraConfig;
  };
}
