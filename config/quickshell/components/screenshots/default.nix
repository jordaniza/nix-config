{config, lib, pkgs, makeMenu, ...}: let
  screenshotCopy = pkgs.writeShellApplication {
    name = "screenshot-copy";
    runtimeInputs = [pkgs.coreutils pkgs.wl-clipboard];
    text = builtins.readFile ./copy-screenshot.sh;
  };
in {
  packages = [(makeMenu "screenshot-history" "screenshots" "Screenshots")];
  settings = {
    screenshotCopy = lib.getExe screenshotCopy;
    screenshotDirectory = "${config.home.homeDirectory}/Pictures/Screenshots";
  };
}
