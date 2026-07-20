{
  home.file = {
    "pwd-lyse-maven-update.sh" = {
      text = ''
        #!/usr/bin/env nix-shell
        #!nix-shell -i bash -p maven
        set -euo pipefail

        IPA_PW=$(bw-sudo get password 4fab525d-7b81-4421-8813-b084006afed4)
        [ -n "$IPA_PW" ] || { echo "error: empty password from bitwarden" >&2; exit 1; }

        # mvn must run inside the nix-shell above; the previous version called it
        # outside and would silently write an empty maven password.
        MVN_ENCRYPTED_PW=$(mvn --encrypt-password "$IPA_PW")
        case "$MVN_ENCRYPTED_PW" in
          '{'*'}') ;;
          *) echo "error: unexpected mvn encrypt output" >&2; exit 1 ;;
        esac

        DOCKER_AUTH=$(printf 'kimei:%s' "$IPA_PW" | base64 -w0)

        sops --set "[\"lyse\"][\"maven\"][\"password\"] \"$MVN_ENCRYPTED_PW\"" /etc/nixos/secrets/secrets.yaml
        sops --set "[\"lyse\"][\"docker\"][\"auth\"] \"$DOCKER_AUTH\"" /etc/nixos/secrets/secrets.yaml

        echo "updated lyse maven password and docker auth in sops"
      '';
      target = ".local/bin/pwd-lyse-maven-update";
      executable = true;
    };
  };
}
