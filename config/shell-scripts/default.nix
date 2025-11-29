{...}: {
  home.file.".config/autostart/copyq.desktop" = {
    source = ./copyq.desktop;
  };

  home.file.".local/bin/cq" = {
    source = ./cq.sh;
    executable = true;
  };

  home.file.".local/bin/bat-or-glow" = {
    source = ./bat-or-glow.sh;
    executable = true;
  };

  home.file.".local/bin/close-meet" = {
    source = ./close-meet.sh;
    executable = true;
  };

  home.file.".local/bin/kitty-rename" = {
    source = ./kitty-rename.sh;
    executable = true;
  };

  home.file.".local/bin/toggle-floating" = {
    source = ./toggle-floating.sh;
    executable = true;
  };
}
