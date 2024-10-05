{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    #autosuggestions.enable = true;

    syntaxHighlighting.enable = true;

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
        # {name = "jeffreytse/zsh-vi-mode";}
      ];
    };

    shellAliases = {
      cd = "z";
      cat = "bat";
      ssh-dt = "kitty +kitten ssh jordan@dt";
      whatsapp = "whatsapp-for-linux";
      ls = "lfcd";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.zshrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default --impure";
      nixedit = "cd ~/.nix && nvim";
      dev = "cd ~/Documents/dev/ && ls";
      crypto = "cd ~/Documents/dev/crypto && ls";
      aragon = "cd ~/Documents/dev/crypto/aragon/ && ls";
      clearswap = "rm -rf ~/.local/state/nvim/swap/*";
      ft = "forge test";
      fs = "forge script";
      fb = "forge build";
      # neofetch = "fastfetch";
    };
    initExtra = ''
      bindkey '^I' autosuggest-accept
      unset SSH_ASKPASS
      export PATH="${config.home.homeDirectory}/.npm-packages/bin:${pkgs.nodejs}/bin:$PATH";
      export NODE_PATH="${config.home.homeDirectory}/.npm-packages/lib/node_modules";

                    lfcd () {
               cd "$(command lf -print-last-dir "$@")"
                    }
    '';
  };
}
