{ inputs, config, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    ./disko.nix
    ./nvidia.nix
    ./pipewire.nix
    ./virtualisation.nix
    ../../mixins/programs/steam.nix    
  ];
 
  # Enable Steam
  programs.steam = {
    protontricks.enable = true;
    gamescopeSession = {
      enable = true;
    };
  };

  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.budgie.enable = true;
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "netbrain";
  
  
  services.xserver.config = ''
    Section "ServerLayout"
      Identifier "TwinLayout"
      Screen 0 "metaScreen" 0 0
  EndSection

  Section "Monitor"
      Identifier "Monitor0"
      Option "Enable" "true"
  EndSection

  Section "Device"
      Identifier "Card0"
      Driver "nvidia"
      VendorName "NVIDIA Corporation"
      Option "MetaModes" "1920x1080"
      Option "ConnectedMonitor" "DP-0"
      Option "ModeValidation" "NoDFPNativeResolutionCheck,NoVirtualSizeCheck,NoMaxPClkCheck,NoHorizSyncCheck,NoVertRefreshCheck,NoWidthAlignmentCheck"
  EndSection

  Section "Screen"
      Identifier "metaScreen"
      Device "Card0"
      Monitor "Monitor0"
      DefaultDepth 24
      Option "TwinView" "True"
      SubSection "Display"
          Modes "1920x1080"
      EndSubSection
  EndSection
  '';

  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };

  environment.systemPackages = with pkgs; [ 
    protontricks 
    gamescope
    cudatoolkit linuxPackages.nvidia_x11
    cudaPackages.cudnn
    libGLU
    libGL
  ];

  services.tailscale.enable = true;
  services.plex.enable = true;
  
  services = {
    sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      package = pkgs.sunshine.override {
        cudaSupport = true;
      };
    };
  };
  
}
