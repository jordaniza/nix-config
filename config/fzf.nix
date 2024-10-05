{
  config,
  pkgs,
  ...
}: {
  lib,
  config,
  pkgs,
  ...
}: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };
}
