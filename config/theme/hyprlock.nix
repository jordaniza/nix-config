{
  config,
  lib,
  pkgs,
  ...
}: let
  palette = import ./palette.nix;
in {
  programs.hyprlock.settings = lib.mkIf config.programs.hyprlock.enable {
    animations.animation = ["fadeIn, 0"];

    background = [
      {
        monitor = "";
        path = "${config.home.homeDirectory}/Pictures/wallpaper.png";
        color = "rgb(${palette.background})";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.65;
        noise = 0.01;
      }
    ];

    label = [
      {
        monitor = "";
        text = "$TIME";
        font_family = palette.monoFont;
        font_size = 64;
        color = "rgb(${palette.foreground})";
        position = "0, 160";
        halign = "center";
        valign = "center";
      }
      {
        monitor = "";
        text = "cmd[update:60000] ${pkgs.coreutils}/bin/date '+%A, %d %B'";
        font_family = palette.uiFont;
        font_size = 16;
        color = "rgb(${palette.muted})";
        position = "0, 85";
        halign = "center";
        valign = "center";
      }
    ];

    input-field = [
      {
        monitor = "";
        size = "300, 56";
        position = "0, -30";
        halign = "center";
        valign = "center";
        fade_on_empty = true;
        placeholder_text = "";
        font_family = palette.uiFont;
        outline_thickness = 0;
        rounding = builtins.fromJSON palette.cornerRadius;
        dots_center = true;
        dots_size = 0.16;
        dots_spacing = 0.5;
        inner_color = "rgba(${palette.background}00)";
        outer_color = "rgba(${palette.selection}00)";
        font_color = "rgb(${palette.foreground})";
        swap_font_color = true;
        check_color = "rgb(${palette.accent})";
        fail_color = "rgb(${palette.critical})";
        fail_text = "Try again";
      }
    ];
  };
}
