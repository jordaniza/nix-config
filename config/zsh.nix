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
      cq = "${config.home.homeDirectory}/.local/bin/cq";
      cat = "${config.home.homeDirectory}/.local/bin/bat-or-glow";
      ssh-dt = "kitty +kitten ssh jordan@dt";
      ssh-local = "kitten ssh jordan@192.168.1.238";
      whatsapp = "whatsapp-for-linux";
      ls = "lfcd";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.zshrc";
      rl = "reload";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default --impure && reload";
      nu = "nixup";
      clearswap = "rm -rf ~/.local/state/nvim/swap/*";
      # forge commands
      ft = "forge test";
      fs = "forge script";
      fb = "forge build";
      # git commands
      gst = "git status";
      gsw = "git switch";
      gchb = "git checkout -b";
      ga = "git add";
      gaa = "git add .";
      gc = "git commit -m";
      gpsho = "git push origin";
      gpsh = "git push";
      gpllo = "git pull origin";
      gpll = "git pull";
      gbr = "git branch";
      gbrr = "git branch | grep \*";
      x = "exit";

      # print last llm log in nicely formatted markdown
      lll = "llm logs -r | cat --language=markdown";
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
      export EDITOR="nvim";
      export VISUAL="nvim";
      export ZSH_AUTOSUGGEST_HISTORY_IGNORE="?(#c100,)";

      lfcd () {
        cd "$(command lf -print-last-dir "$@")"
      }

      cl() { cat "$@" | wl-copy; }

      if [[ -n "$SSH_CONNECTION" ]]; then
        export PROMPT="(ssh) %n@%m %~ ->> "
      else
        export PROMPT="%n@%m %~ ->> "
      fi

      zvm_after_init_commands+=('bindkey -M viins "gf" zvm_exit_insert_mode')

    '';
  };
}
