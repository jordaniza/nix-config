{
  pkgs,
  lib,
  ...
}: let
  vimrcContent = ''
    " =========================
    " Obsidian Vim Configuration
    " =========================

    set clipboard=unnamed
    set number
    set relativenumber
    set tabstop=4
    set shiftwidth=4
    set expandtab

    " Insert mode mappings
    inoremap gf <Esc>
    let mapleader="\<Space>"
    inoremap <leader>gf <Esc>

    " Normal mode mappings
    nnoremap <C-l> <C-w>l
    nnoremap <C-h> <C-w>h
    nnoremap <leader>/ :nohlsearch<CR>
    nnoremap <leader>b ^
    nnoremap <leader>e $
    nnoremap <C-s> :w<CR>
    inoremap <C-s> <Esc>:w<CR>a
    vnoremap <C-s> <Esc>:w<CR>

    " Optional: jk to escape from insert
    inoremap jk <Esc>
  '';
in {
  programs.obsidian = {
    enable = true;

    defaultSettings = {
      communityPlugins = [
        "obsidian-vimrc-support"
      ];
      extraFiles = {
        ".obsidian.vimrc" = {
          text = vimrcContent;
        };
      };
    };
  };
}
