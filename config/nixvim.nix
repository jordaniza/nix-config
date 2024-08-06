{ pkgs, ... }:
{
  # neovim w. nixvim
  programs.nixvim = {
    enable = true;
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };  
    clipboard = {
      register = "unnamedplus";
    };
    globals.mapleader = " ";
     
    keymaps = [
    # Toggle NvimTree
    {
      mode = "n";
      key = "<C-n>";
      action = ":NvimTreeToggle<CR>";
      options = {
        silent = true;
        desc = "Toggle NvimTree";
      };
    }

    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd l') end<CR>";
      options = {
        silent = true;
        desc = "Move to buffer from NvimTree";
      };
    }

    # Move to NvimTree from buffer
    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd h') end<CR>";
      options = {
        silent = true;
        desc = "Move to NvimTree from buffer";
      };
    }
    ];

    colorschemes.dracula.enable = true;
    plugins = {
      auto-session = {
	enable = true;
	autoRestore.enabled = true;
	autoSave.enabled = true;
	autoSession = {
	  enabled = true;
	  enableLastSession = true;
	  useGitBranch = true;
	};
      };

      nvim-tree = {
	enable = true;
      };

      lightline = {
	enable = true;
      };

      lsp = {
        enable = true;
	servers = {

	  tsserver.enable = true;

	  rust-analyzer = {
	    installRustc = true;
	    enable = true;
	    installCargo = true;
	  };
	};
      };
    };
    
    extraPlugins = with pkgs.vimPlugins; [ nvim-web-devicons ];

  };
}
