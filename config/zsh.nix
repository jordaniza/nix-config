{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

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
        {
          name = "zsh-users/zsh-autosuggestions";
        }
      ];
    };

    shellAliases = {
      cd = "z";
      cat = "bat";
      ssh-dt = "kitty +kitten ssh jordan@dt";
      ssh-local = "kitten ssh jordan@192.168.1.238";
      whatsapp = "whatsapp-for-linux";
      ls = "lfcd";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.zshrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default --impure && reload";
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

    initExtraFirst = ''
      function zvm_config() {
        ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_ZLE
      }
    '';

    initExtra = ''
      bindkey '^I' autosuggest-accept
      unset SSH_ASKPASS
      export PATH="${config.home.homeDirectory}/.npm-packages/bin:${pkgs.nodejs}/bin:$PATH";
      export NODE_PATH="${config.home.homeDirectory}/.npm-packages/lib/node_modules";

      lfcd () {
        cd "$(command lf -print-last-dir "$@")"
      }

      if [[ -n "$SSH_CONNECTION" ]]; then
        export PROMPT="(ssh) %n@%m %~ ->> "
      else
        export PROMPT="%n@%m %~ ->> "
      fi

      zvm_after_init_commands+=('bindkey -M viins "gf" zvm_exit_insert_mode')

    '';
  };
}
