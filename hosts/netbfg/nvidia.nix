{ config, pkgs, ... }:
{
  hardware = {
    opengl =
      let
        fn = oa: {
          nativeBuildInputs = oa.nativeBuildInputs ++ [ pkgs.glslang ];
          mesonFlags = oa.mesonFlags ++ [ "-Dvideo-codecs=h264enc,h265enc" ];
        };
      in
      with pkgs; {
        enable = true;
        #driSupport32Bit = true;
        package = (mesa.overrideAttrs fn).drivers;
        #package32 = (pkgsi686Linux.mesa.overrideAttrs fn).drivers;
      };
  };


  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = true; 
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia.open = false;

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.nvidiaPersistenced = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
#  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
#  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
}
