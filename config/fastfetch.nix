# TODO: get this working with a good sized logo - neofetch is fine for now
{
  programs.fastfetch = {
    enable = true;
    settings = {
      logo = {
        source = "nixos_medium";
        height = 18; # Adjust logo height for a smaller size
      };
      display = {
        separator = " : ";
      };
      modules = [
        {
          type = "os";
          key = "   OS";
          keyColor = "38;5;19";
        }
        {
          type = "kernel";
          key = "   Kernel";
          keyColor = "97";
        }
        {
          type = "packages";
          key = "  󰏗 Packages";
          keyColor = "34";
        }
        {
          type = "display";
          key = "  󱍜 Display";
          keyColor = "38;5;208";
        }
        {
          type = "wm";
          key = "   WM";
          keyColor = "38;5;81";
        }
        {
          type = "terminal";
          key = "   Terminal";
          keyColor = "90";
        }
        {
          type = "command";
          key = "  󱦟 Age ";
          keyColor = "38;5;124";
        }
        {
          type = "uptime";
          key = "   Uptime";
          keyColor = "34";
        }
        {
          type = "title";
          key = "   User";
          keyColor = "38;5;250";
        }
        {
          type = "cpu";
          format = "{1}";
          key = "   CPU";
          keyColor = "38;5;118";
        }
        {
          type = "gpu";
          format = "{2}";
          key = "   GPU";
          keyColor = "38;5;220";
        }
        {
          type = "gpu";
          format = "{3}";
          key = "   GPU Driver";
          keyColor = "38;5;27";
        }
        {
          type = "memory";
          key = "   Memory";
          keyColor = "38;5;99";
        }
        {
          type = "custom";
          format = "";
        }
        "break"
      ];
    };
  };
}
