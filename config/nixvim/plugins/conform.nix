{
  enable = true;
  settings = {
    formatters_by_ft = {
      css = ["prettierd" "prettier"];
      html = ["prettierd" "prettier"];
      javascript = ["prettierd" "prettier"];
      javascriptreact = ["prettier"];
      json = ["prettier"];
      jsonc = ["prettier"];
      lua = ["stylua"];
      markdown = ["prettier"];
      nix = ["alejandra"];
      python = ["black"];
      rust = ["rustfmt"];
      # bit janky atm - put a prettierrc in the root and it works
      solidity = ["prettier"];
      sh = ["shfmt"];
      sql = ["sqlfluff"];
      typescript = ["prettierd" "prettier"];
      typescriptreact = ["prettier"];
      yaml = ["prettierd" "prettier"];
    };
    format_on_save = {
      lsp_fallback = true;
      timeout_ms = 2000;
    };
    formatters.sqlfluff = {
      command = "sqlfluff";
      stdin = true;
      #
      # # Critical: run from a "root" so .sqlfluff is discovered
      # cwd.__raw = ''
      #   require("conform.util").root_file({
      #     ".sqlfluff",
      #     "pyproject.toml",
      #     ".git",
      #   })
      # '';

      # No hardcoded dialect here: sqlfluff will read it from .sqlfluff
      args = ["format" "-"];

      # Prevent non-zero exit (e.g. "unfixable violations") from blocking save-format
      ignore_exitcode = true;
    };
  };
}
