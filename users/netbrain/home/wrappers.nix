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
        LOCAL_DIR=""
        ARGS=()

        while [[ $# -gt 0 ]]; do
          case $1 in
            --repo)
              REPO_URL="$2"
              shift 2
              ;;
            --local)
              LOCAL_DIR="$2"
              shift 2
              ;;
            *)
              ARGS+=("$1")
              shift
              ;;
          esac
        done

        # Auto-detect git repo if not specified and not using local dir
        if [ -z "$REPO_URL" ] && [ -z "$LOCAL_DIR" ]; then
          REPO_URL=$(git remote -v 2>/dev/null | awk '{print $2}' | head -n1 || echo "")
        fi

        # Create persistent Nix store volume if it doesn't exist
        # This volume is shared across all containers for efficiency
        if ! podman volume exists nix-store 2>/dev/null; then
          podman volume create nix-store
        fi

        # Build podman command
        PODMAN_CMD=(podman run -it --rm)
        PODMAN_CMD+=(--init)
        PODMAN_CMD+=(--shm-size=4g)
        PODMAN_CMD+=(--security-opt label=disable)
        PODMAN_CMD+=(--device /dev/fuse)
        PODMAN_CMD+=(-v nix-store:/nix:rw)
        PODMAN_CMD+=(-v "$(readlink -f ~/.ssh/id_rsa):/tmp/host-ssh/id_rsa:ro")
        PODMAN_CMD+=(-v "$HOME/.config/git/config:/tmp/host-git/config:ro")
        PODMAN_CMD+=(-v "$HOME/.config/gh:/tmp/host-gh:ro")
        PODMAN_CMD+=(-v "$HOME/.claude:/tmp/host-claude:ro")
        PODMAN_CMD+=(-v "$HOME/.claude.json:/tmp/host-claude.json:ro")

        # Mount local directory or use REPO_URL
        if [ -n "$LOCAL_DIR" ]; then
          PODMAN_CMD+=(-v "$LOCAL_DIR:/workspace:rw")
        elif [ -n "$REPO_URL" ]; then
          PODMAN_CMD+=(-e "REPO_URL=$REPO_URL")
        fi

        # Add image and command/arguments
        PODMAN_CMD+=(claude-code)

        # Only add arguments if provided
        if [ ''${#ARGS[@]} -gt 0 ]; then
          PODMAN_CMD+=("''${ARGS[@]}")
        fi

        exec "''${PODMAN_CMD[@]}"
      '';
    };
  };
}
