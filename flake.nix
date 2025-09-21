{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim should be declared here
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    nixvim,
    rust-overlay,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          foundry-bin = final.callPackage ./foundry-bin {};
        })
      ];
    };

    # detect the device for hardware specific stuff
    # Fetch the machine-id from /etc/machine-id
    machineId = builtins.replaceStrings ["\n"] [""] (builtins.readFile "/etc/machine-id");

    # Determine the device based on the machine-id from /etc/machine-id
    device = (
      if machineId == "be2ddb959d5646dfb65446e0b9be05ed"
      then
        (
          builtins.trace "Machine ID: ${machineId}, using desktop configuration"
          "desktop"
        )
      else if machineId == "a8bdaefc14bf4f0aa5d96468ceb313d9"
      then
        (
          builtins.trace "Machine ID: ${machineId}, using laptop configuration"
          "laptop"
        )
      else abort "Unknown machine-id: ${machineId}"
    );

    hardwareConfig =
      if device == "desktop"
      then ./devices/desktop.nix
      else ./devices/laptop.nix;

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
    #
    # overlay = final: prev: {
    #   foundry-bin = final.callPackage ./foundry-bin {};
    # };

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs device;};
      modules = [
        hardwareConfig
        ./configuration.nix
        home-manager.nixosModules.default
        {
          environment.systemPackages = [
            foundry-bin
            pkgs.rust-bin.stable.latest.default
          ];
          home-manager.sharedModules = [nixvim.homeManagerModules.nixvim];
        }
      ];
    };
  };
}
