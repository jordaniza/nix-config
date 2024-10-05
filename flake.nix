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

    # detect the device for hardware specific stuff
    # Fetch the machine-id from /etc/machine-id
    machineId = builtins.replaceStrings ["\n"] [""] (builtins.readFile "/etc/machine-id");

    # Determine the correct hardware configuration based on machine-id
    hardwareConfig = (
      if machineId == "be2ddb959d5646dfb65446e0b9be05ed"
      then
        (
          builtins.trace "Machine ID: ${machineId}, using desktop configuration"
          ./devices/desktop.nix
        )
      else if machineId == "your-laptop-machine-id"
      then
        (
          builtins.trace "Machine ID: ${machineId}, using laptop configuration"
          ./devices/laptop.nix
        )
      else abort "Unknown machine-id: ${machineId}"
    );

    # import foundry related utilities
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
        hardwareConfig
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
