# LLM install doesn't play nicely with nixOS so we have to install the plugins
# directly via nixpkgs and python. Also this relies on a later version of Nix so
# we use the unstable version
{unstable, ...}:
unstable.python313.withPackages (ps: [
  ps.llm
  ps.llm-gemini
  ps.llm-anthropic
])
