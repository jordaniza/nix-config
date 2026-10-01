{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    brave-nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixvim should be declared here
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
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
        # The pinned overlay uses "" where newer fetchurl expects null.
        (final: prev:
          rust-overlay.overlays.default
            (final // {
              fetchurl = args:
                prev.fetchurl (args // (
                  if (args.name or null) == ""
                  then {name = null;}
                  else {}
                ));
            })
            prev)
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
      then ./hardware/desktop.nix
      else ./hardware/laptop.nix;
  in {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {inherit inputs device;};
      modules = [
        hardwareConfig
        ./configuration.nix
        home-manager.nixosModules.default
        {
          environment.systemPackages = [
            pkgs.rust-bin.stable.latest.default
          ];
          home-manager.sharedModules = [nixvim.homeModules.nixvim];
        }
      ];
    };
  };
}
