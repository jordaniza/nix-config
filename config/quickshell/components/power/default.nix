{lib, pkgs, makeMenu, quickshell, shellConfig, ...}: let
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
in {
  packages = [(makeMenu "power-menu" "power" "Power menu") powerStatus];
  statusPackages = [powerStatus];
  settings.powerAction = lib.getExe powerAction;
}
