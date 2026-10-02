{
  lib,
  pkgs,
  ...
}: let
  files = import ./render.nix {inherit pkgs;};
in {
  imports = [./gtk.nix ./hyprlock.nix];

  programs.kitty.extraConfig = lib.mkAfter "include ${files.kitty}";
  programs.tmux.extraConfig = lib.mkAfter "source-file ${files.tmux}";

  xdg.configFile = {
    "theme/hyprland.conf".source = files.hyprland;
    "theme/mako.conf".source = files.mako;
    "waybar/style.css".source = files.waybar;
    "wofi/style.css".source = files.wofi;
  };
}
