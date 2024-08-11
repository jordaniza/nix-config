{
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
}
