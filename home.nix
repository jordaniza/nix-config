{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    (import ./config/packages.nix {inherit pkgs;})
    (import ./config/git.nix {inherit pkgs;})
    (import ./config/dconf.nix {inherit pkgs;})
    (import ./config/chromium.nix {inherit pkgs;})
    (import ./config/nixvim {inherit pkgs;})
    (import ./config/bash.nix {inherit config pkgs;})
    ./config/kitty.nix
    ./config/ssh.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.

  home.homeDirectory = "/home/jordan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  nixpkgs.config.allowUnfree = true;

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/jordan/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # allow some global installs using npm
    TEST = "TICKLES";
    #PATH = "${config.home.homeDirectory}/.npm-packages/bin:${pkgs.nodejs}/bin:$PATH";
    #NODE_PATH = "${config.home.homeDirectory}/.npm-packages/lib/node_modules";
  };

  home.activation = {
    installNpmPackages =
      lib.hm.dag.entryAfter ["writeBoundary"]
      ''
        # Ensure the npm packages directory exists
        mkdir -p ${config.home.homeDirectory}/.npm-packages/lib/node_modules

        # Configure npm to use the home directory for global installations
        echo "prefix=${config.home.homeDirectory}/.npm-packages" > ${config.home.homeDirectory}/.npmrc

        # Install npm packages globally
        ${pkgs.nodejs}/bin/npm install -g  @nomicfoundation/solidity-language-server
      '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
