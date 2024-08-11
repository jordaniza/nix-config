{
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
}
