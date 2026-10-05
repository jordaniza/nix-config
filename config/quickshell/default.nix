{config, lib, pkgs, ...}: let
  quickshell = lib.getExe config.programs.quickshell.package;
  shellConfig = "${config.xdg.configHome}/quickshell";
  powerAction = pkgs.writeShellApplication {
    name = "power-action";
    text = ''
      case "''${1-}" in
        lock) exec ${pkgs.systemd}/bin/loginctl lock-session ;;
        suspend) exec ${pkgs.systemd}/bin/systemctl suspend ;;
        restart) exec ${pkgs.systemd}/bin/shutdown -r now ;;
        shutdown) exec ${pkgs.systemd}/bin/shutdown now ;;
        *) echo "Unknown power action" >&2; exit 2 ;;
      esac
    '';
  };
  powerStatus = pkgs.writeShellApplication {
    name = "power-menu-status";
    runtimeInputs = [pkgs.coreutils pkgs.procps];
    text = ''
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
    '' + builtins.readFile ./power-status.sh;
  };
  screenshotCopy = pkgs.writeShellApplication {
    name = "screenshot-copy";
    runtimeInputs = [pkgs.coreutils pkgs.wl-clipboard];
    text = builtins.readFile ./copy-screenshot.sh;
  };
  makeMenu = name: target: title: pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = [pkgs.coreutils pkgs.libnotify];
    text = ''
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
      readonly menu_target=${lib.escapeShellArg target}
      readonly menu_title=${lib.escapeShellArg title}
    '' + builtins.readFile ./open-menu.sh;
  };
  powerMenu = makeMenu "power-menu" "power" "Power menu";
  screenshotHistory = makeMenu "screenshot-history" "screenshots" "Screenshots";
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
        "PATH=${lib.makeBinPath [powerStatus]}:/run/current-system/sw/bin"
      ];
    };
  };
  home.packages = [powerMenu powerStatus screenshotHistory];
  xdg.configFile = {
    "quickshell/config.json".text = builtins.toJSON {
      powerAction = lib.getExe powerAction;
      screenshotCopy = lib.getExe screenshotCopy;
      screenshotDirectory = "${config.home.homeDirectory}/Pictures/Screenshots";
    };
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
