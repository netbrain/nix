{ config, ... }:

{
  sops.secrets = {
    "github/token" = { };
  };

  sops.templates."nix.conf" = {
    content = ''
      access-tokens = github.com=${config.sops.placeholder."github/token"}
    '';
    path = "/home/netbrain/.config/nix/nix.conf";
  };
}
