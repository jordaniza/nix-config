{
  config,
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
    "quickshell/theme".source = config.lib.file.mkOutOfStoreSymlink "${config.xdg.configHome}/theme/quickshell";
    "theme/quickshell/Theme.qml".source = files.quickshell;
    "theme/quickshell/qmldir".source = ./quickshell/qmldir;
    "theme/quickshell/MenuSurface.qml".source = ./quickshell/MenuSurface.qml;
    "theme/quickshell/MenuRow.qml".source = ./quickshell/MenuRow.qml;
    "theme/quickshell/MenuError.qml".source = ./quickshell/MenuError.qml;
    "theme/quickshell/PowerAppearance.qml".source = ./quickshell/PowerAppearance.qml;
    "theme/quickshell/Icons.qml".source = ./quickshell/Icons.qml;
    "theme/hyprland.conf".source = files.hyprland;
    "theme/mako.conf".source = files.mako;
    "waybar/style.css".source = files.waybar;
    "wofi/style.css".source = files.wofi;
  };
}
