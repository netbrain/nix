{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, ... }:
  let
    # Import the combined configuration logic from lib/default.nix
    lib = (inputs.nixpkgs.lib // inputs.home-manager.lib // (import ./lib/default.nix { inherit inputs; }));

    # Call mkConfig once to generate both NixOS + HM and  Standalone Home Manager configurations
    config = lib.mkConfig {
      hostname = "netmiles";
      users = [ "netbrain" ];
    };
  in
  {
    # Expose the nixosConfigurations and homeConfigurations from the single mkConfig call
    nixosConfigurations = config.nixosConfigurations;
    homeConfigurations = config.homeConfigurations;
  };
}
