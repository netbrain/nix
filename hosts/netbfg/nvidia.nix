{ config, ... }:
{	
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = true; 
  hardware.nvidia-container-toolkit.enable = false;
  hardware.nvidia.open = false;

  services.xserver.videoDrivers = [ "nvidia" ];
}
