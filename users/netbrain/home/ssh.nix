{ config, ... }:
{
  programs.ssh = {
    enable = true;

    matchBlocks = {
      # Work GitHub (Lyse) - explicit alias
      "github.com-lyse" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_lyse";
      };

      # Personal GitHub - default github.com
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
      };
    };
  };
}
