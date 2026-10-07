{
  config,
  lib,
  pkgs,
  ...
}: let
  quickshell = lib.getExe config.programs.quickshell.package;
  shellConfig = "${config.xdg.configHome}/quickshell";
  makeMenu = import ./shared {inherit lib pkgs quickshell shellConfig;};
  features = map (path:
    import path {
      inherit config lib pkgs makeMenu quickshell shellConfig;
    }) [./components/power ./components/screenshots ./components/tmux ./components/controls];
  settings = lib.foldl' (settings: feature: settings // feature.settings) {} features;
  statusPackages = lib.concatMap (feature: feature.statusPackages or []) features;
in {
  programs.quickshell = {
    enable = true;
    systemd.enable = true;
  };
  systemd.user.services.quickshell = {
    # This desktop starts Hyprland directly, without a systemd session target.
    # Hyprland's login/logout hooks own when this service runs.
    Install.WantedBy = lib.mkForce [];
    Unit = {
      ConditionEnvironment = ["WAYLAND_DISPLAY" "HYPRLAND_INSTANCE_SIGNATURE"];
      StartLimitIntervalSec = 30;
      StartLimitBurst = 3;
    };
    Service = {
      ExecStart = lib.mkForce "${quickshell} --path ${lib.escapeShellArg shellConfig} --no-duplicate";
      RestartSec = 2;
      # Restart=on-failure is supplied by the Home Manager module.
      Environment = [
        "PATH=${lib.makeBinPath statusPackages}:/run/current-system/sw/bin"
      ];
    };
  };
  home.packages = lib.concatMap (feature: feature.packages) features;
  xdg.configFile = {
    "quickshell/config.json".text = builtins.toJSON settings;
    "quickshell/shell.qml".source = ./shell.qml;
    "quickshell/shared" = {
      source = ./shared;
      recursive = true;
    };
    "quickshell/components" = {
      source = ./components;
      recursive = true;
    };
  };
}
