{ pkgs, config, ... }:
{

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      # sync.enable = true;
      offload = {
        # Example script
        # export __NV_PRIME_RENDER_OFFLOAD=1
        # export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
        # export __GLX_VENDOR_LIBRARY_NAME=nvidia
        # export __VK_LAYER_NV_optimus=NVIDIA_only
        # exec "$@"

        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      (vaapiIntel.override { enableHybridCodec = true; })
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
