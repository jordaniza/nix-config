{pkgs, ...}: {
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
    #    folding = true;
    nixvimInjections = true;
    grammarPackages = pkgs.vimPlugins.nvim-treesitter.allGrammars;
  };

  # fmt
  # autosave will work but make sure you have things installed
  conform-nvim = {
    enable = true;
    formattersByFt = {
      css = ["prettierd" "prettier"];
      html = ["prettierd" "prettier"];
      javascript = ["prettierd" "prettier"];
      javascriptreact = ["prettier"];
      json = ["prettier"];
      lua = ["stylua"];
      markdown = ["prettier"];
      nix = ["alejandra"];
      python = ["black"];
      rust = ["rustfmt"];
      # bit janky atm - put a prettierrc in the root and it works
      solidity = ["prettier"];
      sh = ["shfmt"];
      typescript = ["prettierd" "prettier"];
      typescriptreact = ["prettier"];
      yaml = ["prettierd" "prettier"];
    };
    formatOnSave = {
      lspFallback = true;
      timeoutMs = 2000;
    };
  };

  lsp = {
    enable = true;

    keymaps = {
      lspBuf = {
        gd = "definition";
        gi = "implementation";
        rn = "rename";
      };
    };

    servers = {
      # nix
      nil-ls.enable = true;

      # ts
      tsserver.enable = true;

      # rust
      rust-analyzer = {
        installRustc = false;
        enable = true;
        installCargo = false;
      };

      # python
      pyright.enable = true;
    };
  };
}
