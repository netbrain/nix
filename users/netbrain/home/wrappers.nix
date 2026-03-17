{ config, pkgs, lib, ... }:

{
  home.file = {
    ".local/bin/bw-sudo" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        BW="${pkgs.bitwarden-cli}/bin/bw"
        KEYCTL="${pkgs.keyutils}/bin/keyctl"
        PINENTRY="${pkgs.pinentry-qt}/bin/pinentry"
        KEY_DESC="bw-sudo:session"

        get_session() {
          local key_id
          key_id=$($KEYCTL search @s user "$KEY_DESC" 2>/dev/null) || true
          if [ -n "$key_id" ]; then
            $KEYCTL pipe "$key_id" 2>/dev/null || true
          fi
        }

        store_session() {
          echo -n "$1" | $KEYCTL padd user "$KEY_DESC" @s >/dev/null
        }

        clear_session() {
          local key_id
          key_id=$($KEYCTL search @s user "$KEY_DESC" 2>/dev/null) || true
          if [ -n "$key_id" ]; then
            $KEYCTL unlink "$key_id" @s 2>/dev/null || true
          fi
        }

        get_master_password() {
          local response
          response=$(printf "SETDESC Bitwarden Master Password\nSETPROMPT Password:\nGETPIN\n" | $PINENTRY 2>/dev/null)
          echo "$response" | grep "^D " | sed 's/^D //'
        }

        case "''${1:-}" in
          lock)
            clear_session
            $BW lock >/dev/null 2>&1 || true
            echo "bw-sudo: session locked"
            exit 0
            ;;
          status)
            session=$(get_session)
            if [ -n "$session" ] && BW_SESSION="$session" $BW unlock --check >/dev/null 2>&1; then
              echo "bw-sudo: unlocked"
            else
              echo "bw-sudo: locked"
            fi
            exit 0
            ;;
        esac

        session=$(get_session)

        if [ -z "$session" ] || ! BW_SESSION="$session" $BW unlock --check >/dev/null 2>&1; then
          master_pw=$(get_master_password)
          if [ -z "$master_pw" ]; then
            echo "bw-sudo: no password provided" >&2
            exit 1
          fi

          session=$(echo "$master_pw" | $BW unlock --raw 2>/dev/null) || {
            echo "bw-sudo: unlock failed" >&2
            exit 1
          }

          store_session "$session"
        fi

        export BW_SESSION="$session"
        exec $BW "$@"
      '';
    };


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

        # Rebuild claude-code image
        echo "Building claude-code image..."
        podman build -t claude-code "$HOME/dev/dockerfiles/claude-code"

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
          # Map container UID 1000 (podman) to host UID 1000 so bind-mounted files
          # have correct ownership. Without this, rootless podman's sub-UID remapping
          # causes files to appear as UID 100999 inside the container.
          # Mapping: 0:0:1000 = container 0-999 -> sub-UIDs (root for entrypoint)
          #          1000:1000:1 = container 1000 -> host 1000 (identity map)
          #          1001:1001:64536 = container 1001-65535 -> sub-UIDs (rest)
          HOST_UID=$(id -u)
          HOST_GID=$(id -g)
          PODMAN_CMD+=(--uidmap "0:1:''${HOST_UID}")
          PODMAN_CMD+=(--uidmap "''${HOST_UID}:0:1")
          PODMAN_CMD+=(--uidmap "$((HOST_UID + 1)):$((HOST_UID + 1)):$((65536 - HOST_UID - 1))")
          PODMAN_CMD+=(--gidmap "0:1:''${HOST_GID}")
          PODMAN_CMD+=(--gidmap "''${HOST_GID}:0:1")
          PODMAN_CMD+=(--gidmap "$((HOST_GID + 1)):$((HOST_GID + 1)):$((65536 - HOST_GID - 1))")
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
