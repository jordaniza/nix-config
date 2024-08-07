{ pkgs, ... }: 
{
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

  # search
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

  # code formatting
  conform-nvim = {
    
    enable = true;

    # Define formatters by file type
    formattersByFt = {
      "*" = [ "codespell" ];
      "_" = [ "trim_whitespace" ];
      javascript = [ "prettierd" "prettier" ];
      json = [ "jq" ];
      lua = [ "stylua" ];
      nix = [ "alejandra" ];
      python = [ "isort" "black" ];
      rust = [ "rustfmt" ];
	sh = [ "shfmt" ];
    };

        # Autocommand for formatting on save
    formatOnSave = ''
        require('conform').format()
    '';
  };

  lsp = {
    enable = true;

    servers = {

      # nix
      nil-ls.enable = true;

      # ts
      tsserver.enable = true;

      # rust
      rust-analyzer = {
	installRustc = true;
	enable = true;
	installCargo = true;
      };
    };
  };
}
