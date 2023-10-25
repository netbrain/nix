{pkgs, ... }:

{
  virtualisation.docker = {
    enable = true;
    enableNvidia = true;
    enableOnBoot = true;
    extraOptions = ''--config-file=${
      pkgs.writeText "daemon.json" (builtins.toJSON {
        features = { buildkit = true; };
      })
    }'';
  };

  # Required by enableNvidia
  hardware.opengl.driSupport32Bit = true;
}
