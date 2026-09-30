{device, lib, ...}: {
  imports = [ (./devices + "/${device}.nix") ];

  xdg.configFile = {
    "hypr/hyprland.conf".text = lib.mkBefore (builtins.readFile ./hyprland.conf);
    "hypr/hyprpaper.conf".source = ./hyprpaper.conf;
    "hypr/scripts/pane-layout.sh" = {
      source = ./scripts/pane-layout.sh;
      executable = true;
    };

    "waybar/style.css".source = ../waybar/style.css;
    "waybar/power_menu.xml".source = ../waybar/power_menu.xml;

    "wofi/config".source = ../wofi/config;
    "wofi/style.css".source = ../wofi/style.css;

    "mako/config".source = ../mako/config;
  };
}
