{...}: {
  home.file.".config/autostart/copyq.desktop" = {
    source = ./copyq.desktop;
  };

  home.file.".local/bin/cq" = {
    source = ./cq.sh;
    executable = true;
  };

  home.file.".local/bin/open-slack" = {
    source = ./slack.sh;
    executable = true;
  };
}
