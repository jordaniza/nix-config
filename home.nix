{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "jordan";
  home.homeDirectory = "/home/jordan";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
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

    # editors
    vscode

    # javascript
    nodejs_22
    bun

    # python
    python3 

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ] ++ (with pkgs.gnomeExtensions; [
    burn-my-windows
    blur-my-shell
    gtile
    clipboard-history
  ]);

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

  # configure brave
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    # extension IDs are found in the URL of the chrome store
    extensions = [
      "ldcoohedfbjoobcadoglnnmmfbdlmmhf" # frame companion
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "gphhapmejobijbbhgpjhcjognlahblep" # GNOME shell
    ];
  };


  # configure git
  programs.ssh = {
    enable = true;

  };

  programs.git = {
    enable = true;
    userName = "jordaniza";
    userEmail = "j@jordaniza.com";

    extraConfig = {
      init.defaultBranch = "main";
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "lf";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.bashrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default";
    };
    bashrcExtra = ''
      neofetch
      unset SSH_ASKPASS
    '';
  };


  nixpkgs.config = {
    allowUnfree = true;
  };

   dconf = {
    enable = true;
    settings = {
      # configure system settings
      "org/gnome/desktop/interface" = {
         color-scheme = "prefer-dark";
      };

      # setup the extensions here
      "org/gnome/shell" = {
        disable-user-extensions = false; # allow user extensions
        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          burn-my-windows.extensionUuid
          clipboard-history.extensionUuid
          gtile.extensionUuid
        ];
      };

      # config the extensions here
      "org/gnome/shell/extensions/blur-my-shell" = {
	brightness = 0.75;
        noise-amount = 0;
      };

      "org/gnome/shell/extensions/clipboard-history" = {
	paste-on-selection = false;
	toggle-menu = ["<Super>v"];
      };

      "org/gnome/shell/extensions/burn-my-windows" = {
        last-extension-version = 42;
	last-prefs-version = 42;
	prefs-open-count = 1;
	# todo: default to the hexagon effect - takes 2 seconds but would be nice to do it declaratively
      };
    };
  };

  # neovim w. nixvim
  programs.nixvim = {
    enable = true;
    options = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };  
     
    colorschemes.dracula.enable = true;
    plugins.lightline.enable = true;
  };

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
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
