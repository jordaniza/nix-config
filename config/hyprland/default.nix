{device, lib, pkgs, ...}: {
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
    "hypr/hyprland.conf".text = lib.mkBefore (builtins.readFile ./hyprland.conf);
    "hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    "hypr/scripts/pane-layout.sh" = {
      source = ./scripts/pane-layout.sh;
      executable = true;
    };

    "waybar/power_menu.xml".source = ../waybar/power_menu.xml;

    "wofi/config".source = ../wofi/config;

    "mako/config".source = ../mako/config;
  };
}
