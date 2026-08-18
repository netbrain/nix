{ inputs }:
let
  lib = inputs.nixpkgs.lib // inputs.home-manager.lib;
in
rec {
  # Define mkSystem for NixOS configuration
  mkSystem = { hostname, system ? "x86_64-linux", users ? [ ] }:
    builtins.trace "Calling mkSystem for ${hostname}!"
    inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Load stylix (can't load both hm and nixos module)
        # inputs.stylix.nixosModules.stylix
        
        # Load Home Manager module for NixOS
        inputs.home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = false;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbackup";

          # Make sure specialArgs are passed to Home Manager modules
          home-manager.extraSpecialArgs = { inherit inputs hostname; };
          
          home-manager.users = lib.listToAttrs (lib.map (user: {
            name = user;
            value = {
              imports = [
                # Load stylix
                inputs.stylix.homeModules.stylix
                
                # Load flatpak
                inputs.flatpaks.homeManagerModules.nix-flatpak

                # Load sops
                inputs.sops-nix.homeManagerModules.sops

                # Load wrappimage
                inputs.wrappimage.homeModules.wrappimage
                
                ../users/${user}/home
                ../hosts/${hostname}/home
              ];
            };
          }) users);
        }

        # Load system-specific configuration (hostname.nix or hostname/default.nix)
        ../hosts/${hostname}

        # Load diskos
        inputs.disko.nixosModules.disko

        {
          # System configurations
          networking.hostName = hostname;
          nix.settings.trusted-users = [ "root" "@wheel" ];
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          # Automatic store maintenance (nix store on netmiles shares a single
          # 922G partition; without this, builds eventually fail on a full disk)
          nix.gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 14d";
          };
          nix.optimise.automatic = true;

          # Keep boot entries bounded (each is a no-op for the disabled loader)
          boot.loader.systemd-boot.configurationLimit = 10;
          boot.loader.grub.configurationLimit = 10;

          # Binary cache for sadjow/claude-code-nix (avoids building claude locally)
          nix.settings.extra-substituters = [ "https://claude-code.cachix.org" ];
          nix.settings.extra-trusted-public-keys = [ "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk=" ];

          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnsupportedSystem = false;
          
          # Add each input as a registry (for flakes)
          nix.registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v: inputs.nixpkgs.lib.nameValuePair n { flake = v; })
            inputs;
        }

        # Load zwift
        inputs.zwift.nixosModules.zwift
        
      ] ++ lib.map (u: ../users/${u}) users; # Load each user's specific system configuration
    };

  # Define mkHome for Home Manager configurations per user
  mkHome = { username, system ? "x86_64-linux", hostname, stateVersion ? "24.05" }:
    builtins.trace "Calling mkHome for ${username}!"
    inputs.home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit system hostname inputs;
      };
      pkgs = builtins.getAttr system inputs.nixpkgs.outputs.legacyPackages;

      modules = [
        # Load stylix
        inputs.stylix.homeModules.stylix

        # Load flatpak
        inputs.flatpaks.homeManagerModules.nix-flatpak

        # Load sops
        inputs.sops-nix.homeManagerModules.sops

        # Load wrappimage
        inputs.wrappimage.homeModules.wrappimage
      
        # Load user-specific home configuration (home.nix or home/default.nix)
        ../users/${username}/home

        # Load host-specific home configuration, same as the NixOS-integrated
        # home-manager in mkSystem does
        ../hosts/${hostname}/home

        {
          # Home Manager specific configuration for each user
          nixpkgs.config.allowUnfree = true;
          nixpkgs.config.allowUnsupportedSystem = false;
          programs.home-manager.enable = true;

          # Home Manager-specific settings for the user
          home = {
            inherit username stateVersion;
            homeDirectory = "/home/${username}";
          };
        }
      ];
    };

  mkConfig = { hosts }: {
    nixosConfigurations = lib.listToAttrs (map (host: {
      name = host.hostname;
      value = mkSystem {
        hostname = host.hostname;
        system = host.system or "x86_64-linux";
        users = host.users or [];
      };
    }) hosts);

    homeConfigurations = lib.mergeAttrsList (map (host:
      lib.listToAttrs (map (user: {
        name = "${user}@${host.hostname}";
        value = mkHome {
          username = user;
          system = host.system or "x86_64-linux";
          hostname = host.hostname;
        };
      }) host.users or [])
    ) hosts);
  };
}
