{lib, pkgs, makeMenu, quickshell, shellConfig, ...}: let
  themeFiles = import ../../../theme/render.nix {inherit pkgs;};
  tmuxStatus = pkgs.writeShellApplication {
    name = "tmux-status";
    runtimeInputs = [pkgs.coreutils pkgs.procps pkgs.jq];
    text = ''
      readonly tmux=${lib.escapeShellArg (lib.getExe pkgs.tmux)}
      readonly counts_format_file=${lib.escapeShellArg "${themeFiles.waybarTmuxCounts}"}
      readonly quickshell=${lib.escapeShellArg quickshell}
      readonly shell_config=${lib.escapeShellArg shellConfig}
    '' + builtins.readFile ./tmux-status.sh;
  };
in {
  packages = [(makeMenu "tmux-menu" "tmux" "tmux") tmuxStatus];
  statusPackages = [tmuxStatus];
  settings.tmux = lib.getExe pkgs.tmux;
}
