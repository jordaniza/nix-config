{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "lf";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.bashrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default";
      nixedit = "cd ~/.nix && nvim";
      dev = "cd ~/Documents/dev/ && ls";
      crypto = "cd ~/Documents/dev/crypto && ls";
      aragon = "cd ~/Documents/dev/crypto/aragon/ && ls";
      clearswap = "rm -rf ~/.local/state/nvim/swap/*";
    };
    bashrcExtra = ''
      neofetch
      unset SSH_ASKPASS
    '';
  };
}
