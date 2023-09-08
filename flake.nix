{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nvidia-vgpu.url = "github:physics-enthusiast/nixos-nvidia-vgpu/525.125";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: {

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
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [
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
      };

    };
}
