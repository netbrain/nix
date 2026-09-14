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

          session=$($BW unlock --passwordfile <(printf '%s' "$master_pw") --raw 2>/dev/null) || {
            echo "bw-sudo: unlock failed" >&2
            exit 1
          }

          store_session "$session"
        fi

        export BW_SESSION="$session"
        exec $BW "$@"
      '';
    };


    ".local/bin/vpn-lyse" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        BW_SUDO="${config.home.homeDirectory}/.local/bin/bw-sudo"
        NMCLI="${pkgs.networkmanager}/bin/nmcli"
        ID="4fab525d-7b81-4421-8813-b084006afed4"

        # Reconnect cleanly if the VPN is already up
        if "$NMCLI" -t -f NAME connection show --active | grep -qx Lyse; then
          "$NMCLI" connection down Lyse
        fi

        pw=$("$BW_SUDO" get password "$ID")
        otp=$("$BW_SUDO" get totp "$ID")

        # Feed the password (password immediately followed by TOTP, no
        # separator) to nmcli via an fd — never via argv, env, or the
        # clipboard, and without xargs/echo re-parsing the secret.
        "$NMCLI" connection up Lyse \
          passwd-file <(printf 'vpn.secrets.password:%s%s\n' "$pw" "$otp")
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

    # open-design (OpenDesign): lokal design-app som lar kodeagenter produsere
    # HTML/PDF/PPTX/MP4. Kjøres som container, ikke som nix-pakke: upstream
    # publiserer ingen Linux-binær, og kilden er en pnpm 10.33-monorepo med
    # seks workspaces, Next.js-bygg, better-sqlite3 og Electron.
    #
    # Flaggene speiler deploy/docker-compose.yml fra upstream. Vi bruker ikke
    # deres docker-compose.linux.yml: den bind-monterer /lib/x86_64-linux-gnu,
    # som ikke finnes på NixOS.
    #
    # Host-CLI-ene gjøres i stedet synlige ved å montere /nix/store read-only
    # sammen med brukerprofilens bin/. Nix-binærer har absolutt RPATH og
    # ELF-interpreter inne i storet, så de kjører i dette Alpine-imaget uten
    # glibc-mountene upstream trenger på Debian. Verifisert: claude, codex og
    # opencode rapporteres alle "available" av /api/agents.
    #
    # ~/.claude monteres bevisst IKKE. Upstream gjør det, men det ville gitt en
    # tredjepartscontainer lesetilgang til Claude-credentials. Legg det til selv
    # hvis du vil at claude skal være autentisert inne i containeren.
    #
    # Minnegrensen er hevet fra upstreams 384m til 1g: agent-deteksjon toppet
    # 443 MB og ble OOM-drept (exit 137) på lavere grenser.
    #
    # Telemetri rapporterte "effectiveMode: off, blockedReason: missing_sink"
    # i denne oppsettformen, altså ingen aktiv sink.
    ".local/bin/open-design" = {
      executable = true;
      text = ''
        #!/usr/bin/env bash
        set -euo pipefail

        # Bevisst PATH-oppslag og ikke ${pkgs.podman}: rootless podman virker bare
        # med binæren virtualisation.podman setter opp (setuid newuidmap/newgidmap,
        # storage.conf, policy.json). pkgs.podman er en annen store-path enn
        # systemets og ville i tillegg duplisert podman i closure.
        # Samme grep som claude-container-wrapperen over.
        PODMAN="podman"
        IMAGE="''${OPEN_DESIGN_IMAGE:-ghcr.io/nexu-io/od:latest}"
        PORT="''${OPEN_DESIGN_PORT:-7456}"
        NAME="open-design"
        TOKEN_FILE="$HOME/.config/open-design/token"

        # API-tokenet ligger utenfor sops fordi det bare beskytter en
        # loopback-bundet lokal tjeneste og genereres på maskinen.
        ensure_token() {
          if [ ! -s "$TOKEN_FILE" ]; then
            mkdir -p "$(dirname "$TOKEN_FILE")"
            ${pkgs.openssl}/bin/openssl rand -hex 32 > "$TOKEN_FILE"
            chmod 600 "$TOKEN_FILE"
            echo "Genererte nytt API-token i $TOKEN_FILE" >&2
          fi
          cat "$TOKEN_FILE"
        }

        start() {
          local token
          token=$(ensure_token)

          if $PODMAN container exists "$NAME" 2>/dev/null; then
            $PODMAN start "$NAME" >/dev/null
          else
            $PODMAN volume exists open_design_data 2>/dev/null \
              || $PODMAN volume create open_design_data >/dev/null

            # Ingen --restart-policy: rootless podman håndhever den via
            # podman-restart.service, som ikke er aktivert her, og Linger=no
            # stopper uansett brukerens containere ved utlogging. Kjør
            # "open-design start" på nytt etter reboot.
            # --read-only, --pids-limit og no-new-privileges kommer fra
            # upstreams compose-fil. Porten publiseres kun på loopback:
            # OD_BIND_HOST=0.0.0.0 gjelder inne i containeren.
            $PODMAN run -d \
              --name "$NAME" \
              -p "127.0.0.1:''${PORT}:7456" \
              -e NODE_ENV=production \
              -e NODE_OPTIONS=--max-old-space-size=768 \
              -e OD_BIND_HOST=0.0.0.0 \
              -e OD_PORT=7456 \
              -e "OD_WEB_PORT=''${PORT}" \
              -e "OD_API_TOKEN=''${token}" \
              -v open_design_data:/app/.od \
              -v /nix/store:/nix/store:ro \
              -v "/etc/profiles/per-user/$(id -un)/bin:/mnt/host-bin:ro" \
              -e "PATH=/mnt/host-bin:/usr/local/bin:/usr/bin:/bin" \
              -e HOME=/home/open-design \
              --read-only \
              --tmpfs /tmp \
              --mount type=tmpfs,destination=/home/open-design,tmpfs-mode=1777 \
              --security-opt no-new-privileges:true \
              -m 1g \
              --pids-limit 256 \
              "$IMAGE" >/dev/null
          fi

          echo "open-design kjører på http://127.0.0.1:''${PORT}"
          echo "Logg inn som brukernavn 'open-design' med tokenet i $TOKEN_FILE"
        }

        case "''${1:-start}" in
          start)  start ;;
          stop)   $PODMAN stop "$NAME" ;;
          status) $PODMAN ps --filter "name=$NAME" ;;
          logs)   shift; $PODMAN logs "''${@:---tail=50}" "$NAME" ;;
          token)  ensure_token ;;
          update)
            $PODMAN pull "$IMAGE"
            $PODMAN rm -f "$NAME" 2>/dev/null || true
            start
            ;;
          *)
            echo "Bruk: open-design [start|stop|status|logs|token|update]" >&2
            exit 1
            ;;
        esac
      '';
    };
  };
}
