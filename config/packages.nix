{pkgs, ...}: let
  unstable =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/549bd84d6279f9852cae6225e372cc67fb91a4c1.tar.gz";
      sha256 = "0dchsfq8czjg8iwr60fxmqnglllchcy64wp60b8wx4wd9mwn0rw4";
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
      hcloud
      unstable.proton-vpn-cli
      protonvpn-gui

      # db
      supabase-cli
      sq
      lazysql

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
      dconf-editor
      gnome-tweaks

      # languages
      nodejs_22
      bun
      yarn
      gcc
      uv

      # apps
      discord
      telegram-desktop
      whatsapp-for-linux
      slack

      # utilities
      wl-clipboard
      ripgrep
      lcov
      docker

      # fonts
      fira-code
      fira-code-symbols
      nerd-fonts.fira-code

      # formatters
      alejandra
      black
      prettierd
      shfmt
      stylua
      sqlfluff

      # keyboard
      keyd

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

  # fonts.packages = [pkgs.nerd-fonts.fira-code];
}
