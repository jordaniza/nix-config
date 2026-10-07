{config, device, lib, pkgs, ...}: {
  imports = [ (./devices + "/${device}.nix") ];

  home.packages = with pkgs; [
    wofi
    waybar
    grim
    slurp
    hyprpaper
    mako
    libnotify
    nautilus
    bluetuith
    pulsemixer
    brightnessctl
  ];

  xdg.configFile = {
    "hypr/hyprland.conf".text = lib.mkBefore (
      builtins.readFile ./hyprland.conf + lib.optionalString config.programs.quickshell.systemd.enable ''

        # Supply this session's display details before starting the managed shell.
        exec-once = ${pkgs.systemd}/bin/systemctl --user import-environment WAYLAND_DISPLAY DISPLAY HYPRLAND_INSTANCE_SIGNATURE XDG_CURRENT_DESKTOP XDG_SESSION_TYPE && ${pkgs.systemd}/bin/systemctl --user restart quickshell.service
        exec-shutdown = ${pkgs.systemd}/bin/systemctl --user stop quickshell.service
      ''
    );
    "hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    "hypr/scripts/cycle-floating.sh" = {
      source = ./scripts/cycle-floating.sh;
      executable = true;
    };
    "hypr/scripts/pane-layout.sh" = {
      source = ./scripts/pane-layout.sh;
      executable = true;
    };

    "wofi/config".source = ../wofi/config;

    "mako/config".source = ../mako/config;
  };
}
