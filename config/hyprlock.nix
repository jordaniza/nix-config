{osConfig, ...}: {
  programs.hyprlock = {
    enable = osConfig.programs.hyprland.enable;
    settings.general.grace = 0;
  };
}
