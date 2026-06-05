{
  home.file = {
    "pwd-lyse-maven-update.sh" = {
      text = ''
        #!/usr/bin/env bash

        IPA_PW=$(bw-sudo get password 4fab525d-7b81-4421-8813-b084006afed4)
        MVN_ENCRYPTED_PW=$(mvn --encrypt-password ''${IPA_PW})
        DOCKER_AUTH=$(printf 'kimei:%s' "''${IPA_PW}" | base64 -w0)

        nix-shell -p maven --run "
          sops --set '[\"lyse\"][\"maven\"][\"password\"] \"''${MVN_ENCRYPTED_PW}\"' /etc/nixos/secrets/secrets.yaml
          sops --set '[\"lyse\"][\"docker\"][\"auth\"] \"''${DOCKER_AUTH}\"' /etc/nixos/secrets/secrets.yaml
        "
      '';
      target = ".local/bin/pwd-lyse-maven-update";
      executable = true;
    };
  };
}
