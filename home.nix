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
  home.file.".config/autostart/copyq.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Exec=env QT_QPA_PLATFORM=xcb copyq
    Hidden=false
    NoDisplay=false
    X-GNOME-Autostart-enabled=true
    Name=CopyQ
    Comment=Clipboard Manager
  '';

  home.file.".local/bin/cq" = {
    executable = true;
    text = ''
      #!/bin/sh

      # A custom CLI for managing CopyQ history.

      case "$1" in
        "" | --help)
          echo "Usage: cq [COMMAND]"
          echo ""
          echo "A simple CLI to manage CopyQ."
          echo ""
          echo "Commands:"
          echo "  list        Show a searchable history menu with fzf."
          echo "  clear       Clear all items from the clipboard history."
          echo "  [numbers]   Print the content of one or more items by index."
          ;;

        list)
          # Use a "here document" (<< 'EOF') to pass the script safely to CopyQ
          selection=$(
            copyq eval - << 'EOF' | fzf --tac | awk -F. '{print $1}'
      if (size() > 0) {
        var l = [];
        for (var i = 0; i < size(); ++i) {
          l.push(i + ". " + str(read(i)).split("\n")[0]);
        }
        print(l.join("\n"));
      }
      EOF
          )

          if [ -n "$selection" ]; then
            copyq select "$selection"
          fi
          ;;

        clear)
          count=$(copyq count)
          if [ "$count" -gt 0 ]; then
            copyq remove $(seq 0 $((count - 1)))
          fi
          echo "CopyQ history cleared."
          ;;

        *)
          copyq read "$@"
          ;;
      esac
    '';
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
