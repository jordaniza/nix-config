{lib, ...}: {
  imports = [ ./desktop/hypridle.nix ];

  xdg.configFile."hypr/hyprland.conf".text = lib.mkAfter ''
    # Desktop monitors
    monitor=DP-4,3440x1440@144.00Hz,0x0,1
    monitor=DP-1,3440x1440@144.00Hz,0x0,1
  '';
}
