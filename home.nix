{
  lib,
  config,
  pkgs,
  ...
}: {
  imports = [
    (import ./config/packages.nix {inherit pkgs;})
    (import ./config/git.nix {inherit pkgs;})
    (import ./config/dconf.nix {inherit config pkgs;})
    (import ./config/chromium.nix {inherit pkgs;})
    (import ./config/zsh.nix {inherit config pkgs;})
    (import ./config/nixvim {inherit config pkgs;})
    (import ./config/vscode {inherit config pkgs;})
    (import ./config/tmux.nix {inherit config pkgs;})
    (import ./config/bat.nix {inherit config pkgs;})
    (import ./config/fzf.nix {inherit config pkgs;})
    (import ./config/zoxide.nix {inherit config pkgs;})
    ./config/kitty.nix
    ./config/ssh.nix
    ./config/gpg-agent.nix
    ./config/shell-scripts
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
  home.stateVersion = "25.05"; # Please read the comment before changing.
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.

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
    # TODO I am not sure why but these variables seem to be ignored by bash so
    # if you need them, set in the bashrc
  };

  home.activation = {
    # don't run this on every activation, otherwise it delays the boot process
    # todo: doesn't install the package in the expected place
    installNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
      NM_DIR="${config.home.homeDirectory}/.npm-packages/lib/node_modules/"

      if [ ! -d "$NM_DIR/@nomicfoundation/solidity-language-server" ]; then
        mkdir -p $NM_DIR
        echo "prefix=${config.home.homeDirectory}/.npm-packages" > ${config.home.homeDirectory}/.npmrc
        ${pkgs.nodejs}/bin/npm install -g  @nomicfoundation/solidity-language-server prettier-plugin-solidity
      fi
    '';
  };
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
