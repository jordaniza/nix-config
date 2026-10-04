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
  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [pkgs.coreutils pkgs.util-linux pkgs.libnotify];
    text = ''
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
      export POWER_ACTION=${lib.escapeShellArg (lib.getExe powerAction)}
    '' + builtins.readFile ./open-power.sh;
  };
in {
  programs.quickshell.enable = true;
  home.packages = [powerMenu powerStatus];
  xdg.configFile = {
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
