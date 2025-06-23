# LLM install doesn't play nicely with nixOS so we have to install the plugins
# directly via nixpkgs and python. Also this relies on a later version of Nix so
# we use the unstable version
{...}: let
  unstable =
    import (builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/4206c4cb56751df534751b058295ea61357bbbaa.tar.gz";
      sha256 = "11qdsgrzaqmmwmll706q005dbfsfb0h1nhswc4pkldm0hxrlvcal";
    }) {
      config.allowUnfree = true;
    };
in
  unstable.python313.withPackages (ps: [
    ps.llm
    ps.llm-gemini
    ps.llm-anthropic
  ])
