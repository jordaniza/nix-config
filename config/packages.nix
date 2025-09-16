{pkgs, ...}: let
  unstable =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/4206c4cb56751df534751b058295ea61357bbbaa.tar.gz";
      sha256 = "11qdsgrzaqmmwmll706q005dbfsfb0h1nhswc4pkldm0hxrlvcal";
    }) {
      config.allowUnfree = true;
    };

  python-with-pkgs = import ./pythonPkgs.nix {inherit pkgs unstable;};
in {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      # unstable
      python-with-pkgs
      unstable.claude-code

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
      copyq
      wmctrl
      glow

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

      # apps
      discord
      telegram-desktop
      whatsapp-for-linux
      slack

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
