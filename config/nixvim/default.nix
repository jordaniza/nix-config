{ pkgs, ... }:
{

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

    plugins = (import ./plugins { inherit pkgs; });

    extraPlugins = with pkgs.vimPlugins; [ nvim-web-devicons ];
  };
}