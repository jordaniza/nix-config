{lib, ...}: {
  xdg.configFile."waybar/config.jsonc".source = ../../waybar/laptop.jsonc;

  xdg.configFile."hypr/hyprland.conf".text = lib.mkAfter ''
    # Preserve the laptop's existing display and HDMI mirroring rules.
    monitor=,preferred,auto,1
    monitor=,preferred,auto,1,mirror,HDMI-A-1
  '';
}
