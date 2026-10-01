# Install LLM and its plugins together in the stable Python environment.
{pkgs, ...}:
pkgs.python313.withPackages (ps: [
  ps.llm
  ps.llm-gemini
  ps.llm-anthropic
])
