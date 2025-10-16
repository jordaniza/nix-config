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
    nil_ls.enable = true;

    # ts
    ts_ls.enable = true;

    # rust
    rust_analyzer = {
      installRustc = false;
      enable = true;
      installCargo = false;
    };

    # python
    pyright.enable = true;
  };
}
