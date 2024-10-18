{ inputs, config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./nvidia.nix
    ./pipewire.nix
    ../../mixins/programs/river.nix
    ../../mixins/services/greetd.nix
    ../../mixins/programs/steam.nix    
  ];
 
  # Enable Steam
  programs.steam = {
    protontricks.enable = true;
    gamescopeSession = {
      enable = true;
    };
  };

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [ protontricks gamescope ];

  services.tailscale.enable = true;
  services.plex.enable = true;
  
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
    };
  };
  
}
