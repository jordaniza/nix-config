{pkgs, inputs, ...}: let
  python-with-pkgs = import ./pythonPkgs.nix {inherit pkgs;};
  # Preserve the Node implementation; stable pkgs.live-server is unrelated.
  live-server-node =
    inputs.rust-overlay.inputs.nixpkgs
    .legacyPackages.${pkgs.stdenv.hostPlatform.system}
    .nodePackages.live-server;
in {
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs;
    [
      python-with-pkgs
      claude-code

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

      # db
      supabase-cli
      sq
      lazysql
      postgresql

      # git
      gh
      git

      # terminal
      kitty

      # editors
      dconf-editor

      # languages
      nodejs_22
      bun
      yarn
      pnpm
      live-server-node
      gcc
      uv
      foundry

      # apps
      discord
      telegram-desktop
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
      prettier
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
    ];

  # fonts.packages = [pkgs.nerd-fonts.fira-code];
}
