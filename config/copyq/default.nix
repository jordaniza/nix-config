# config/copyq.nix
{pkgs, ...}: {
  home.file.".config/autostart/copyq.desktop" = {
    source = ./copyq.desktop;
  };

  home.file.".local/bin/cq" = {
    source = ./cq.sh;
    executable = true;
  };
}
