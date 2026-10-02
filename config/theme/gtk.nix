{
  config,
  pkgs,
  ...
}: let
  palette = import ./palette.nix;
in {
  # Use supported dark appearance and a named accent for GTK/libadwaita apps.
  gtk = {
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    font = {
      name = palette.uiFont;
      size = 11;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = true;
    gtk4.theme = config.gtk.theme;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    accent-color = palette.gnomeAccent;
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    GTK_APPLICATION_PREFER_DARK_THEME = "1";
  };
}
