{pkgs, ...}: {
  # neovim w. nixvim
  programs.nixvim = {
    enable = true;

    colorschemes.dracula.enable = true;

    # out the box options
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    # share clipboard with the os
    clipboard = {
      register = "unnamedplus";
    };

    globals.mapleader = " ";

    keymaps = import ./keymaps.nix;

    plugins = import ./plugins {inherit pkgs;};

    extraPlugins = with pkgs.vimPlugins; [
      nvim-web-devicons
      nvim-lspconfig
      #   vim-solidity
    ];

    extraConfigLua = ''
                    local lspconfig = require('lspconfig')
                    local configs = require 'lspconfig.configs'

          -- odd formatting
                    configs.solidity = {
               default_config = {
                 cmd = {'nomicfoundation-solidity-language-server', '--stdio'},
                 filetypes = { 'solidity' },
                 root_dir = lspconfig.util.find_git_ancestor,
                 single_file_support = true,
               },
                    }

      lspconfig.solidity.setup {}

    '';
  };
}
