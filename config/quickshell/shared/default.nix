{lib, pkgs, quickshell, shellConfig}:
name: target: title: pkgs.writeShellApplication {
  inherit name;
  runtimeInputs = [pkgs.coreutils pkgs.libnotify];
  text = ''
    readonly quickshell=${lib.escapeShellArg quickshell}
    readonly shell_config=${lib.escapeShellArg shellConfig}
    readonly menu_target=${lib.escapeShellArg target}
    readonly menu_title=${lib.escapeShellArg title}
  '' + builtins.readFile ./open-menu.sh;
}
