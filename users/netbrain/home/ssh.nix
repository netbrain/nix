{ config, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    # New API: settings use raw ssh_config(5) directive names (matchBlocks is
    # now a deprecated alias). Field mapping per home-manager legacyBlockSettings.
    settings = {
      # Preserve the values home-manager previously injected implicitly.
      "*" = {
        ForwardAgent = false;
        AddKeysToAgent = "no";
        Compression = false;
        ServerAliveInterval = 0;
        ServerAliveCountMax = 3;
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "no";
        ControlPath = "~/.ssh/master-%r@%n:%p";
        ControlPersist = "no";
      };

      # Work GitHub (Lyse) - explicit alias
      "github.com-lyse" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_ed25519_lyse";
      };

      # Personal GitHub - default github.com
      "github.com" = {
        HostName = "github.com";
        User = "git";
        IdentityFile = "${config.home.homeDirectory}/.ssh/id_rsa";
      };
    };
  };
}
