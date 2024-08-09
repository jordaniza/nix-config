{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim should be declared here
    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
    foundry-bin = import ./foundry-bin {inherit pkgs;};
  in {
    # setup foundry
    apps = {
      anvil = {
        type = "app";
        program = "${foundry-bin}/bin/anvil";
      };
      chisel = {
        type = "app";
        program = "${foundry-bin}/bin/chisel";
      };
      cast = {
        type = "app";
        program = "${foundry-bin}/bin/cast";
      };
      forge = {
        type = "app";
        program = "${foundry-bin}/bin/forge";
      };
    };

    defaultPackage = foundry-bin;

    devShell = pkgs.mkShell {
      buildInputs = [
        foundry-bin
      ];
    };

    overlay = final: prev: {
      foundry-bin = final.callPackage ./foundry-bin {};
    };

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs;};
      modules = [
        ./configuration.nix
        home-manager.nixosModules.default
        {
          environment.systemPackages = [foundry-bin];
          home-manager.sharedModules = [nixvim.homeManagerModules.nixvim];
        }
      ];
    };
  };
}
