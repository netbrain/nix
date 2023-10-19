{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    hardware.url = "github:nixos/nixos-hardware";
    nvidia-vgpu.url = "github:physics-enthusiast/nixos-nvidia-vgpu/525.125";
  };

 outputs = inputs@{ self, nixpkgs, home-manager, ... }: {
      # NixOS configuration entrypoint
      # Available through 'nixos-rebuild switch --flake .#your-hostname'
      nixosConfigurations = {
        qemu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
            ./common/gui.nix
            ./qemu/configuration.nix
            { networking.hostName = "netqemu"; }
          ];
        };
        netwrk = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs home-manager; };
          system = "x86_64-linux";
          modules = [
            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
            }
            ./common/gui.nix
            ./netwrk/default.nix
            { networking.hostName = "netwrk"; }
          ];
        };
        netbox = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
            ./common/gui.nix
            ./netwrk/configuration.nix
            { networking.hostName = "netbox"; }
          ];
        };
        "wsl-nixos" = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
            ./common/cli.nix
            ./wsl/configuration.nix
            { networking.hostName = "wsl-nixos"; }
          ];
        };
      };
    };
}
