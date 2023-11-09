{ pkgs, inputs, config, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = ../../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/netbrain/.config/sops/age/keys.txt";

    secrets."altibox/security" = {
      owner = "netbrain";
    };
  };

  systemd.services."maven-settings-security" = {
    wantedBy = [ "multi-user.target" ];
    script = ''
      echo "
      <settingsSecurity>
        <master>{$(cat ${config.sops.secrets."altibox/security".path})}</master>
      </settingsSecurity>
      " > settings-security.xml
    '';
    serviceConfig = {
        Type = "oneshot";
        User = "netbrain";
        WorkingDirectory = "/home/netbrain/.m2";
    };
  };
}
