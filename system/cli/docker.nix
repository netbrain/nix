{pkgs, ... }:

{
  hardware.nvidia-container-toolkit.enable = true;
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    extraOptions = ''--config-file=${
      pkgs.writeText "daemon.json" (builtins.toJSON {
        features = { buildkit = true; };
      })
    }'';
  };

  # Required by enableNvidia
  hardware.graphics.enable32Bit = true;
}
