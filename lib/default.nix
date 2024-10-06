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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hmbackup";
          
          home-manager.users = lib.listToAttrs (lib.map (user: {
            name = user;
            value = {
              imports = [
                # Load stylix
                inputs.stylix.homeManagerModules.stylix               
                ../users/${user}/home
                ../hosts/${hostname}/home
              ];
            };
          }) users);
        }

        # Load system-specific configuration (hostname.nix or hostname/default.nix)
        ../hosts/${hostname}

        {
          # System configurations
          networking.hostName = hostname;
          nix.settings.trusted-users = [ "root" "@wheel" ];
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          
          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;

          # Add each input as a registry (for flakes)
          nix.registry = inputs.nixpkgs.lib.mapAttrs'
            (n: v: inputs.nixpkgs.lib.nameValuePair n { flake = v; })
            inputs;
        }
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
        inputs.stylix.homeManagerModules.stylix
      
        # Load user-specific home configuration (home.nix or home/default.nix)
        ../users/${username}/home

        {
          # Home Manager specific configuration for each user
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          nixpkgs.config.allowUnfree = true;
          programs.home-manager.enable = true;

          # Home Manager-specific settings for the user
          home = {
            inherit username stateVersion;
            homeDirectory = "/home/${username}";
          };
        }
      ];
    };

  # Combine system and home configurations
  mkConfig = { hostname, system ? "x86_64-linux", users ? [ ] }: {
    nixosConfigurations = {
      "${hostname}" = mkSystem {
        hostname = hostname;
        users = users;
      };
    };

    homeConfigurations = lib.listToAttrs (map (user: {
      name = "${user}@${hostname}";
      value = mkHome {
        username = user;
        system = system;
        hostname = hostname;
        stateVersion = "23.05";
      };
    }) users);
  };
}
