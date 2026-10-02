{pkgs}: let
  palette = import ./palette.nix;
  gtkColors = pkgs.replaceVars ./gtk-colors.css.in {
    inherit (palette) background foreground selection accent muted warning critical;
  };
in {
  waybar = pkgs.replaceVars ./waybar.css {
    inherit gtkColors;
    inherit (palette) monoFont cornerRadius;
  };
  wofi = pkgs.replaceVars ./wofi.css {
    inherit gtkColors;
    inherit (palette) cornerRadius uiFont;
  };
  kitty = pkgs.replaceVars ./kitty.conf.in {
    inherit
      (palette)
      background
      foreground
      selection
      accent
      muted
      critical
      green
      yellow
      pink
      cyan
      comment
      terminalBlack
      brightRed
      brightGreen
      brightYellow
      brightPurple
      brightPink
      brightCyan
      white
      monoFont
      ;
  };
  tmux = pkgs.replaceVars ./tmux.conf.in {
    inherit (palette) background foreground selection accent green yellow comment;
  };
  mako = pkgs.replaceVars ./mako.conf.in {
    inherit (palette) background foreground accent green critical cornerRadius uiFont;
  };
  hyprland = pkgs.replaceVars ./hyprland.conf.in {
    inherit (palette) accent selection shadow cornerRadius;
  };
}
