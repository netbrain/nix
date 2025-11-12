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

    ".local/bin/claude-container" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Parse arguments
        REPO_URL=""
        ARGS=()

        while [[ $# -gt 0 ]]; do
          case $1 in
            --repo)
              REPO_URL="$2"
              shift 2
              ;;
            *)
              ARGS+=("$1")
              shift
              ;;
          esac
        done

        # Auto-detect git repo if not specified
        if [ -z "$REPO_URL" ]; then
          REPO_URL=$(git remote -v 2>/dev/null | awk '{print $2}' | head -n1 || echo "")
        fi

        # Build docker command
        DOCKER_CMD=(docker run -it --rm)
        DOCKER_CMD+=(-v "$(readlink -f ~/.ssh/id_rsa):/root/.ssh/id_rsa:ro")
        DOCKER_CMD+=(-v "$HOME/.config/git/config:/root/.gitconfig:ro")
        DOCKER_CMD+=(-v "$HOME/.config/gh:/root/.config/gh:ro")
        DOCKER_CMD+=(-v "$HOME/.claude:/tmp/.claude:ro")
        DOCKER_CMD+=(-v "$HOME/.claude.json:/tmp/.claude.json:ro")

        # Add REPO_URL if available
        if [ -n "$REPO_URL" ]; then
          DOCKER_CMD+=(-e "REPO_URL=$REPO_URL")
        fi

        # Add image and command/arguments
        DOCKER_CMD+=(claude-code)

        # Only add arguments if provided
        if [ ''${#ARGS[@]} -gt 0 ]; then
          DOCKER_CMD+=("''${ARGS[@]}")
        fi

        exec "''${DOCKER_CMD[@]}"
      '';
    };
  };
}
