{
  programs.kitty = {
    enable = true;

    # settings are limited to string and ints
    settings = {};

    # floats you can declare here so probably easiest to do it all here
    extraConfig = ''
      disambiguate_escape_codes yes
      map space begin-selection
      map enter copy-to-clipboard
      map alt+v paste_from_clipboard
      map alt+m kitten hints --type=url
      allow_remote_control yes
      enable_shell_integration yes
      shell_integration enabled
      listen_on unix:/tmp/kitty-jordan.sock
    '';
  };
}
