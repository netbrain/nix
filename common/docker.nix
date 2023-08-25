{pkgs, ... }:

{
    virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    extraOptions = ''--config-file=${
      pkgs.writeText "daemon.json" (builtins.toJSON {
        features = { buildkit = true; };
      })
    }'';
  };
}
