{pkgs, ...}: let
  python-with-pkgs = import ./pythonPkgs.nix {inherit pkgs;};
in {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # w3
      trezor-suite

      # hardware
      lm_sensors
      inxi
      pciutils
      pavucontrol
      btop

      # cli utils
      bc
      lf
      trash-cli
      curl
      wget
      gnumake
      jq
      tree
      lsof
      socat

      # random
      # fastfetch
      neofetch

      # git
      gh
      git

      # browser
      brave

      # terminal
      kitty

      # editors
      vscode
      gnome.dconf-editor
      gnome.gnome-tweaks

      # languages
      nodejs_22
      bun
      yarn
      gcc

      # python packages
      python-with-pkgs

      # apps
      discord
      telegram-desktop
      whatsapp-for-linux

      # utilities
      wl-clipboard
      ripgrep
      lcov

      # fonts
      fira-code
      fira-code-symbols
      nerdfonts

      # formatters
      alejandra
      black
      prettierd
      shfmt
      stylua

      # keyboard
      keyd

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
      appindicator
    ])
    ++ (
      with pkgs.nodePackages; [
        prettier
        live-server
        pnpm
      ]
    );
}
