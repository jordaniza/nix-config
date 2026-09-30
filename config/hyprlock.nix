{config, osConfig, pkgs, ...}: {
  programs.hyprlock = {
    enable = osConfig.programs.hyprland.enable;
    settings = {
      general.grace = 0;
      animations.animation = [ "fadeIn, 0" ];

      background = [{
        monitor = "";
        path = "${config.home.homeDirectory}/Pictures/wallpaper.png";
        color = "rgb(202020)";
        blur_passes = 3;
        blur_size = 8;
        brightness = 0.65;
        noise = 0.01;
      }];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_family = "sans-serif";
          font_size = 64;
          color = "rgb(cdd6f4)";
          position = "0, 160";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:60000] ${pkgs.coreutils}/bin/date '+%A, %d %B'";
          font_family = "sans-serif";
          font_size = 16;
          color = "rgb(bac2de)";
          position = "0, 85";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = [{
        monitor = "";
        size = "300, 56";
        position = "0, -30";
        halign = "center";
        valign = "center";
        fade_on_empty = true;
        placeholder_text = "";
        font_family = "sans-serif";
        outline_thickness = 0;
        dots_center = true;
        dots_size = 0.16;
        dots_spacing = 0.5;
        inner_color = "rgba(00000000)";
        outer_color = "rgba(00000000)";
        font_color = "rgb(cdd6f4)";
        swap_font_color = true;
        check_color = "rgb(bac2de)";
        fail_color = "rgb(f38ba8)";
        fail_text = "Try again";
      }];
    };
  };
}
