{config, osConfig, pkgs, ...}: {
  programs.hyprlock = {
    enable = osConfig.programs.hyprland.enable;
    settings = {
      general.grace = 0;

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
        fade_on_empty = false;
        placeholder_text = "Password";
        font_family = "sans-serif";
        rounding = 16;
        outline_thickness = 2;
        dots_center = true;
        inner_color = "rgba(1e1e2eaa)";
        outer_color = "rgba(b4befea0)";
        font_color = "rgb(cdd6f4)";
        check_color = "rgb(a6e3a1)";
        fail_color = "rgb(f38ba8)";
      }];
    };
  };
}
