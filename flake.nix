{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      inherit (self) outputs;
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
    in
    rec {
      # Your custom packages
      # Acessible through 'nix build', 'nix shell', etc
      # packages = forAllSystems (system:
      #  let pkgs = nixpkgs.legacyPackages.${system};
      #  in import ./pkgs { inherit pkgs; }
      #);

      # Devshell for bootstrapping
      # Acessible through 'nix develop' or 'nix-shell' (legacy)
      # devShells = forAllSystems (system:
      #  let pkgs = nixpkgs.legacyPackages.${system};
      #  in import ./shell.nix { inherit pkgs; }
      # );

      # Your custom packages and modifications, exported as overlays
      # overlays = import ./overlays { inherit inputs; };
      # Reusable nixos modules you might want to export
      # These are usually stuff you would upstream into nixpkgs
      # nixosModules = import ./modules/nixos;
      # Reusable home-manager modules you might want to export
      # These are usually stuff you would upstream into home-manager
      # homeManagerModules = import ./modules/home-manager;

      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild switch --flake .#your-hostname'
      nixosConfigurations = {
        qemu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./common/gui.nix
            ./qemu/configuration.nix
            { networking.hostName = "netqemu"; }
          ];
        };
        netwrk = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./common/gui.nix
            ./netwrk/default.nix
            { networking.hostName = "netwrk"; }
          ];
        };
        netbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          system = "x86_64-linux";
          modules = [
            ./common/gui.nix
            ./netwrk/configuration.nix
            { networking.hostName = "netbox"; }
          ];
        };
      };

      # Standalone home-manager configuration entrypoint
      # Available through 'home-manager --flake .#your-username@your-hostname'
      #homeConfigurations = {
      #  # FIXME replace with your username@hostname
      #  "netbrain@netwrk" = home-manager.lib.homeManagerConfiguration {
      #    pkgs = nixpkgs.legacyPackages.x86_64-linux; # Home-manager requires 'pkgs' instance
      #    extraSpecialArgs = { inherit inputs outputs; };
      #    modules = [
      #      # > Our main home-manager configuration file <
      #      ./home-manager/home.nix
      #    ];
      #  };
      #};
    };
}
