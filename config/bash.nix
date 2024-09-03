{
  config,
  pkgs,
  ...
}: {
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "lfcd";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.bashrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default";
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
    bashrcExtra = ''
           neofetch
           unset SSH_ASKPASS
           export PATH="${config.home.homeDirectory}/.npm-packages/bin:${pkgs.nodejs}/bin:$PATH";
           export NODE_PATH="${config.home.homeDirectory}/.npm-packages/lib/node_modules";

           lfcd () {
      cd "$(command lf -print-last-dir "$@")"
           }
    '';
  };
}
