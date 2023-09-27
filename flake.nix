{
  description = "netbrain's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    nvidia-vgpu.url = "github:physics-enthusiast/nixos-nvidia-vgpu/525.125";
    devenv.url = "github:cachix/devenv";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };


 outputs = { self, nixpkgs, devenv, ... } @ inputs:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
    in
    {
      devShell.x86_64-linux = devenv.lib.mkShell {
        inherit inputs pkgs;
        modules = [
          ({ pkgs, ... }: {
            # This is your devenv configuration
            packages = [ pkgs.hello ];

            enterShell = ''
              hello
            '';

            processes.run.exec = "hello";
          })
        ];
      };

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
