{
  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "lf";
      rm = "echo '[INFO]: using trash-cli to remove files\n' && trash";
      vim = "nvim";
      reload = "source ~/.bashrc";
      nixup = "sudo nixos-rebuild switch --flake ~/.nix#default";
      nixedit = "nvim ~/.nix";
    };
    bashrcExtra = ''
      neofetch
      unset SSH_ASKPASS
    '';
  };
}
