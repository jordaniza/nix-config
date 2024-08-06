{
  programs.kitty = {
    enable = true;
    
    # settings are limited to string and ints
    settings = {};

    # floats you can declare here so probably easiest to do it all here
    extraConfig = ''
      background_opacity 0.8
      hide_window_decorations yes
      font_size 13.0
      font_family Fira Code
      letter_spacing 1.5
      enable_ligatures always
    '';
  };
}

