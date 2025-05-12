{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    zwift.url = "github:netbrain/zwift";
    npm-package.url = "github:netbrain/npm-package";
    flatpaks.url = "github:gmodena/nix-flatpak/main";
  };

  outputs = inputs@{ self, ... }:
  let
    # Import the combined configuration logic from lib/default.nix
    lib = (inputs.nixpkgs.lib // inputs.home-manager.lib // (import ./lib/default.nix { inherit inputs; }));

    # Call mkConfig once to generate both NixOS + HM and  Standalone Home Manager configurations
    configuration = lib.mkConfig {
      hosts = [
        {
          hostname = "netmiles";
          users = [ "netbrain" ];
        }
        {
          hostname = "netbox";
          users = [ "netbrain" "elin" ];
        }
        {
          hostname = "netbfg";
          users = [ "netbrain" ];
        }
      ];
    };
  in
  {
    # Expose the nixosConfigurations and homeConfigurations from the single mkConfig call
    nixosConfigurations = configuration.nixosConfigurations;
    homeConfigurations = configuration.homeConfigurations;
  };
}
