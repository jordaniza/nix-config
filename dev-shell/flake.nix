{
  description = "Dev Shell for NixOS";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";

  outputs = {
    self,
    nixpkgs,
  }: {
    devShell.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
    in
      pkgs.mkShell {
        name = "dev-shell";

        buildInputs = [
          pkgs.git
          pkgs.bat
          pkgs.fd
          pkgs.ripgrep
          pkgs.fzf
          pkgs.zsh
        ];

        shellHook = ''
          export IN_DEV_SHELL=1
          source ~/.zshrc
        '';
      };
  };
}
