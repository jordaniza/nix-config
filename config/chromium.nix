{ pkgs, ... }:
{
  # configure brave
  programs.chromium = {
    enable = true;
    package = pkgs.brave;
    # extension IDs are found in the URL of the chrome store
    extensions = [
      "ldcoohedfbjoobcadoglnnmmfbdlmmhf" # frame companion
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "eimadpbcbfnmbkopoojfekhnkhdbieeh" # dark reader
      "nngceckbapebfimnlniiiahkandclblb" # bitwarden
      "gphhapmejobijbbhgpjhcjognlahblep" # GNOME shell
    ];
  };
}
