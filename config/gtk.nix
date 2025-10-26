{pkgs, ...}: {
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  home.sessionVariables = {
    GTK_THEME = "Adwaita:dark";
    GTK_APPLICATION_PREFER_DARK_THEME = "1";
    XDG_CURRENT_DESKTOP = "GNOME";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };
}
