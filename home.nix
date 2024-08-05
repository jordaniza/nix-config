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
         clock-show-seconds = true;
         clock-show-weekday = true;
      };
      
	# launchers
        "org/gnome/settings-daemon/plugins/media-keys" = {
          "custom-keybindings" = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          ];
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          name = "Launch Brave";
          command = "brave";
          binding = "<Super>b";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          name = "Launch Telegram";
          command = "telegram-desktop";
          binding = "<Super>t";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
          name = "Launch Terminal";
          command = "kitty";
          binding = "<Super>t";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
          name = "Launch Discord";
          command = "discord";
          binding = "<Super>d";
        };

      "org/gnome/desktop/wm/keybindings" = {
        toggle-maximize = ["<Super>m"]; 
	close=["<Alt>F4" "<Super>q" "<Alt>AudioPrev" "<Alt>AudioMicMute"];
	move-to-workspace-1=["<Shift><Super>Home" "<Shift><Super>F1" "<Shift><Super>exclam" "<Shift><Super>AudioMute"];
	move-to-workspace-2=["<Shift><Super>F2" "<Shift><Super>at" "<Shift><Super>AudioLowerVolume"];
	move-to-workspace-3=["<Shift><Super>F3" "<Shift><Super>numbersign" "<Shift><Super>AudioRaiseVolume"];
	move-to-workspace-4=["<Shift><Super>F4" "<Shift><Super>dollar" "<Shift><Super>AudioPrev" "<Shift><Super>AudioMicMute"];
	switch-applications=["<Super>Tab"];
	switch-applications-backward=["<Shift><Super>Tab"];
	switch-to-workspace-1=["<Super>Home" "<Super>F1" "<Super>1" "<Super>AudioMute"];
	switch-to-workspace-2=["<Super>F2" "<Super>AudioLowerVolume"];
	switch-to-workspace-3=["<Super>F3" "<Super>3" "<Super>AudioRaiseVolume"];
	switch-to-workspace-4=["<Super>F4" "<Super>4" "<Super>AudioPrev" "<Super>AudioMicMute"];
	switch-windows=["<Alt>Tab"];
	switch-windows-backward=["<Shift><Alt>Tab"];
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

      "org/gnome/shell/extensions/gtile" = {
	action-move-left=[""];
	action-move-right=[""];
	debug=false;
	global-auto-tiling=false;
	global-presets=true;
	grid-sizes="3x3,6x3";
	preset-resize-1=["<Control><Super>KP_1"];
	preset-resize-11=[""];
	preset-resize-12=[""];
	preset-resize-13=[""];
	preset-resize-14=[""];
	preset-resize-15=[""];
	preset-resize-16=[""];
	preset-resize-17=[""];
	preset-resize-18=[""];
	preset-resize-19=[""];
	preset-resize-2=["<Control><Super>KP_2"];
	preset-resize-3=["<Control><Super>KP_3"];
	preset-resize-4=["<Control><Super>KP_4"];
	preset-resize-5=["<Control><Super>KP_5"];
	preset-resize-6=["<Control><Super>KP_6"];
	preset-resize-7=[""];
	preset-resize-8=[""];
	preset-resize-9=[""];
	resize1="3x1 1:1 1:1";
	resize2="3x1 2:1 2:1";
	resize3="3x1 3:1 3:1";
	resize4="3x1 1:1 2:1";
	resize5="6x1 2:1 5:1";
	resize6="3x1 2:1 3:1";
	show-grid-lines=true;
	show-icon=true;
	theme="Minimal Dark";
      };
    };
  };


  # kitty
  programs.kitty = {
    enable = true;
  };

  # neovim w. nixvim
  programs.nixvim = {
    enable = true;
    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };  
     
    colorschemes.dracula.enable = true;
    plugins = {
      lightline = {
	enable = true;
      };
      lsp = {
        enable = true;
	servers = {

	  tsserver.enable = true;

	  rust-analyzer = {
	    installRustc = true;
	    enable = true;
	    installCargo = true;
	  };
	};
      };
    };
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
