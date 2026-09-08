{inputs, pkgs, ...}: {
  # Home Manager installs and wraps Brave through its Chromium module.
  programs.chromium = {
    enable = true;
    package = inputs.brave-nixpkgs.legacyPackages.${pkgs.system}.brave;
    commandLineArgs = [
      # Native Wayland corrupts rendering on the desktop RX580.
      "--ozone-platform=x11"
      "--gtk-version=3"
    ];
    # GPU selection stays automatic so the same module works on the laptop.

    # Extension IDs are found in the URL of the Chrome Web Store.
    extensions = [
      "ldcoohedfbjoobcadoglnnmmfbdlmmhf" # frame companion
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "gphhapmejobijbbhgpjhcjognlahblep" # GNOME shell
    ];
  };
}
