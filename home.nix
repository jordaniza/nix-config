{ config, pkgs, ... }:

{
  imports = [
    ./config/bash.nix
    (import ./config/dconf.nix { inherit pkgs; })
    (import ./config/chromium.nix { inherit pkgs; })
  ];

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
    
    # utilities
    wl-clipboard


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


  nixpkgs.config = {
    allowUnfree = true;
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
    clipboard = {
      register = "unnamedplus";
    };
    globals.mapleader = " ";
     
    keymaps = [
    # Toggle NvimTree
    {
      mode = "n";
      key = "<C-n>";
      action = ":NvimTreeToggle<CR>";
      options = {
        silent = true;
        desc = "Toggle NvimTree";
      };
    }

    {
      mode = "n";
      key = "<C-l>";
      action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd l') end<CR>";
      options = {
        silent = true;
        desc = "Move to buffer from NvimTree";
      };
    }

    # Move to NvimTree from buffer
    {
      mode = "n";
      key = "<C-h>";
      action = "<cmd>lua if require'nvim-tree.view'.is_visible() then vim.cmd('wincmd h') end<CR>";
      options = {
        silent = true;
        desc = "Move to NvimTree from buffer";
      };
    }
    ];

    colorschemes.dracula.enable = true;
    plugins = {
      auto-session = {
	enable = true;
	autoRestore.enabled = true;
	autoSave.enabled = true;
	autoSession = {
	  enabled = true;
	  enableLastSession = true;
	  useGitBranch = true;
	};
      };

      nvim-tree = {
	enable = true;
      };

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
