{ config, ... }:
{	
  nixpkgs.config.nvidia.acceptLicense = true;

  hardware.graphics.enable32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = false; #true
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

  services.xserver.videoDrivers = [ "nvidia" "nvidiaLegacy390" ];

}
