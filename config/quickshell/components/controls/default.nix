{config, lib, pkgs, makeMenu, ...}: {
  packages = [(makeMenu "controls-menu" "controls" "Controls")];
  settings = {
  # The full leader menu: key, label and destination are defined together.
  controlsActions = [
    {key = "p"; label = "Power"; menu = "power";}
    {key = "t"; label = "tmux"; menu = "tmux";}
    {key = "s"; label = "Screenshots"; menu = "screenshots";}
    {
      key = "c"; label = "Clipboard";
      command = [(lib.getExe pkgs.kitty) "--class" "cq-picker" "--title" "Clipboard history"
        "-o" "map=enter" "-o" "map=space" "-e" "${config.home.homeDirectory}/.local/bin/cq" "ls"];
    }
    {
      key = "b"; label = "Bluetooth";
      command = [(lib.getExe pkgs.kitty) "-T" "bluetuith" "-e" (lib.getExe pkgs.bluetuith)];
    }
    {
      key = "i"; label = "Internet";
      command = [(lib.getExe pkgs.kitty) "-T" "nmtui" "-e" "${pkgs.networkmanager}/bin/nmtui"];
    }
    {
      key = "v"; label = "Volume";
      command = [(lib.getExe pkgs.kitty) "-T" "pulsemixer" "-e" (lib.getExe pkgs.pulsemixer)];
    }
  ];
  };
}
