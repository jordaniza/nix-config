{...}: {
  gtk.enable = true;

  home.sessionVariables = {
    XDG_CURRENT_DESKTOP = "GNOME";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };
}
