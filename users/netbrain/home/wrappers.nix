{ config, pkgs, ... }:

{
  home.file = {
    ".local/bin/rsync-resume" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -x
        exec ${pkgs.rsync}/bin/rsync -avh --progress --partial --inplace "$@"
      '';
    };

    ".local/bin/rsync-verify" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -x
        exec ${pkgs.rsync}/bin/rsync -avh --progress --checksum "$@"
      '';
    };

    ".local/bin/rsync-safe" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -x
        exec ${pkgs.rsync}/bin/rsync -avh --progress --partial --append-verify --checksum "$@"
      '';
    };

    ".local/bin/rsync-copy" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -x
        exec ${pkgs.rsync}/bin/rsync -avh --progress "$@"
      '';
    };
  };
}
