{pkgs, ...}: {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # cli utils
      lf
      trash-cli

      # random
      cbonsai
      neofetch

      # git
      gh
      git

      # browser
      brave

      # terminal
      kitty

      # editors
      # vscode
      gnome.dconf-editor

      # javascript
      nodejs_22
      bun

      # python
      python3

      # apps
      discord
      telegram-desktop

      # utilities
      wl-clipboard
      ripgrep

      # fonts
      fira-code
      fira-code-symbols
      nerdfonts

      # formatters
      alejandra
      rustfmt
      black
      prettierd
      shfmt
      stylua

      # # It is sometimes useful to fine-tune packages, for example, by applying
      # # overrides. You can do that directly here, just don't forget the
      # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
      # # fonts?
      (pkgs.nerdfonts.override {fonts = ["FiraCode"];})

      # # You can also create simple shell scripts directly inside your
      # # configuration. For example, this adds a command 'my-hello' to your
      # # environment:
      # (pkgs.writeShellScriptBin "my-hello" ''
      #   echo "Hello, ${config.home.username}!"
      # '')
    ]
    ++ (with pkgs.gnomeExtensions; [
      burn-my-windows
      blur-my-shell
      gtile
      clipboard-history
    ]);
}
