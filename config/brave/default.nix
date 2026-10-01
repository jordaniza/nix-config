{inputs, pkgs, lib, device, customHardware, ...}: let
  isDesktop = device == "desktop";
  bravePackage = inputs.brave-nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.brave;
in {
  # Home Manager installs and wraps Brave through its Chromium module.
  programs.chromium = {
    enable = true;
    package =
      if isDesktop then
        bravePackage.overrideAttrs (old: {
          preFixup = (old.preFixup or "") + ''
            gappsWrapperArgs+=(
              --set DRI_PRIME ${lib.escapeShellArg customHardware.gpu.driPrime}
              --run ${lib.escapeShellArg ''
                if [ ! -c "${customHardware.gpu.renderNode}" ] || [ ! -r "${customHardware.gpu.renderNode}" ]; then
                  printf '%s\n' "Brave: configured GPU render node missing or inaccessible: ${customHardware.gpu.renderNode}" >&2
                  exit 1
                fi
              ''}
            )
          '';
        })
      else bravePackage;
    commandLineArgs = [
      # Native Wayland corrupts rendering on the desktop RX580.
      "--ozone-platform=x11"
      "--gtk-version=3"
    ] ++ lib.optionals isDesktop [
      "--render-node-override=${customHardware.gpu.renderNode}"
    ];

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
