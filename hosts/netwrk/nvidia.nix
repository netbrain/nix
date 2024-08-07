{ pkgs, inputs, config, ... }:
{

  imports = [
    #inputs.nvidia-vgpu.nixosModules.nvidia-vgpu
  ];

  # intel
  #boot.kernelParams = [ "module_blacklist=nouveau" ];
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Enable VGPU
    #vgpu = {
    #  enable = true;
    #  fastapi-dls = {
    #    enable = true;
    #  };
    #};
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = true;
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

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      #intel-media-driver
      #(vaapiIntel.override { enableHybridCodec = true; })
      #vaapiVdpau
      #libvdpau-va-gl
    ];
  };

  
#  systemd.user.services."turn-off-nvidia-gpu" = {
#    description = "turns off the nivida gpu to prevent excessive power drain";
#    serviceConfig = {
#      User = "root";
#      After = "nvidia-vgpud.service";
#      ExecStart = ''
#        nvidia-smi drain -p 0000:01:00.0 -m 1
#      '';
#      ExecStop = ''
#        nvidia-smi drain -p 0000:01:00.0 -m 0
#      '';
#    };
#    wantedBy = [ "multi-user.target" ];
#  };

}
