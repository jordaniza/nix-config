{
  programs.kitty = {
    enable = true;

    theme = "Dracula";

    # settings are limited to string and ints
    settings = {};

    # floats you can declare here so probably easiest to do it all here
    extraConfig = ''
      disambiguate_escape_codes yes
      map space begin-selection
      map enter copy-to-clipboard
      background_opacity 0.9
      hide_window_decorations yes
      font_size 13.0
      font_family Fira Code
      letter_spacing 1.5
      enable_ligatures always
    '';
  };
}
