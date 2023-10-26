{ pkgs, inputs, ... }:
{

  imports = [
    inputs.nvidia-vgpu.nixosModules.nvidia-vgpu
  ];

  # intel
  #boot.kernelParams = [ "module_blacklist=nouveau" ];
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Enable VGPU
    vgpu = {
      enable = true;
      fastapi-dls = {
        enable = true;
      };
    };

    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    # using vgpu instead
    # package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      # sync.enable = true;
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
    };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver
      #(vaapiIntel.override { enableHybridCodec = true; })
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };

}
