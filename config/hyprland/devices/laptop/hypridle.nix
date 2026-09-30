{config, lib, osConfig, pkgs, ...}: let
  hyprctl = "${osConfig.programs.hyprland.package}/bin/hyprctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
in {
  xdg.configFile."hypr/hyprland.conf".text = lib.mkAfter (
    lib.optionalString osConfig.programs.hyprland.enable ''
      exec-once = ${pkgs.hypridle}/bin/hypridle
    ''
  );

  services.hypridle = {
    enable = osConfig.programs.hyprland.enable;
    # Started by Hyprland; avoid a second instance via systemd.
    package = null;
    settings = {
      general = {
        lock_cmd = "${pkgs.procps}/bin/pidof hyprlock || ${lib.getExe config.programs.hyprlock.package}";
        before_sleep_cmd = "${loginctl} lock-session";
        after_sleep_cmd = "${hyprctl} dispatch dpms on";
        inhibit_sleep = 3;
        ignore_dbus_inhibit = false;
        ignore_systemd_inhibit = false;
      };
      listener = [
        {
          timeout = 180;
          on-timeout = "${brightnessctl} -c backlight -s set 10%";
          on-resume = "${brightnessctl} -c backlight -r";
        }
        {
          timeout = 300;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 360;
          on-timeout = "${hyprctl} dispatch dpms off";
          on-resume = "${hyprctl} dispatch dpms on";
        }
        {
          timeout = 1200;
          on-timeout = "${pkgs.systemd}/bin/systemctl suspend";
        }
      ];
    };
  };
}
