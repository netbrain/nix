{ config, pkgs, ... }:
{
  programs.git = {
    enable = true;
    difftastic = {
      enable = true;
      background = "dark";
    };
    userName = "Kim Eik";
    userEmail = "kim@heldig.org";
    aliases = {
      co = "checkout";
      cp = "cherry-pick";
    };
    extraConfig = {
      #url."git@github.com:netbrain".insteadOf = [ "https://github.com/netbrain" ];
      url."git@github.com:".insteadOf = [ "gh:" "github:" ];
      push.autoSetupRemote = true;
      core.editor = "hx";
      core.hooksPath = "${config.home.homeDirectory}/.config/git/hooks";
      push.default = "upstream";
      #branch.autoSetupMerge = "simple";
    };
    includes = [{
      path = "~/.gitconfig-lyse";
      condition = "gitdir:~/dev/lyse/";
    }];
  };

  home.file.".gitconfig-lyse" = {
    text = ''
      [user]
      name = Kim Eik
      email = kim.eik@lyse.no

      [url "git@github.com-lyse:"]
      insteadOf = https://github.com/

      [url "git@github.com-lyse:"]
      insteadOf = git@github.com:
    '';
  };

  # Generic git hook dispatcher that runs hooks from both global and local .d directories
  home.file.".config/git/hooks/hook-dispatcher" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      # Git Hook Dispatcher
      # ===================
      #
      # This script enables running multiple git hooks from both global and local directories.
      # It's designed to be symlinked by specific hook names (e.g., prepare-commit-msg, pre-commit).
      #
      # DIRECTORY STRUCTURE:
      #   Global hooks: ~/.config/git/hooks/<hook-name>.d/
      #   Local hooks:  .git/hooks/<hook-name>.d/
      #
      # EXECUTION ORDER:
      #   1. Global hooks run first (alphabetically)
      #   2. Local hooks run second (alphabetically)
      #   3. If a local hook has the same filename as a global hook, the global hook is skipped
      #
      # USAGE:
      #   Add global hooks:
      #     Create executable files in ~/.config/git/hooks/<hook-name>.d/
      #     Example: ~/.config/git/hooks/prepare-commit-msg.d/lumen-commit-msg
      #
      #   Add local repo-specific hooks:
      #     Create executable files in .git/hooks/<hook-name>.d/
      #     Example: .git/hooks/prepare-commit-msg.d/custom-validation
      #
      #   Override global hook:
      #     Create a local hook with the same filename as the global hook
      #     Example: .git/hooks/prepare-commit-msg.d/lumen-commit-msg overrides the global one
      #
      #   Add new hook types:
      #     Create a symlink: ln -s hook-dispatcher ~/.config/git/hooks/pre-commit
      #     Add hooks to: ~/.config/git/hooks/pre-commit.d/
      #
      # ERROR HANDLING:
      #   If any hook exits with non-zero status, execution stops and git aborts the operation
      #
      # NOTES:
      #   - Hooks must be executable (chmod +x)
      #   - Both regular files and symlinks are supported
      #   - Non-executable files are silently skipped
      #   - Alphabetical ordering allows numeric prefixes for explicit ordering (e.g., 10-first, 20-second)

      # Determine which hook was called (e.g., prepare-commit-msg, pre-commit, etc.)
      HOOK_NAME="$(basename "$0")"

      # Get the git repository root
      GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || echo "")"

      # Define hook directories
      GLOBAL_HOOKS_DIR="${config.home.homeDirectory}/.config/git/hooks/''${HOOK_NAME}.d"
      LOCAL_HOOKS_DIR="''${GIT_DIR}/hooks/''${HOOK_NAME}.d"

      # Collect all hook files
      declare -A global_hooks
      declare -A local_hooks

      # Scan global hooks directory
      if [ -d "$GLOBAL_HOOKS_DIR" ]; then
        while IFS= read -r -d "" hook; do
          [ -x "$hook" ] || continue
          hook_basename="$(basename "$hook")"
          global_hooks["$hook_basename"]="$hook"
        done < <(find "$GLOBAL_HOOKS_DIR" -maxdepth 1 \( -type f -o -type l \) -print0 | sort -z)
      fi

      # Scan local hooks directory
      if [ -d "$LOCAL_HOOKS_DIR" ]; then
        while IFS= read -r -d "" hook; do
          [ -x "$hook" ] || continue
          hook_basename="$(basename "$hook")"
          local_hooks["$hook_basename"]="$hook"
          # Remove global hook with same name (local overrides global)
          unset global_hooks["$hook_basename"]
        done < <(find "$LOCAL_HOOKS_DIR" -maxdepth 1 \( -type f -o -type l \) -print0 | sort -z)
      fi

      # Run global hooks (in alphabetical order, excluding overridden ones)
      for hook_name in "''${!global_hooks[@]}"; do
        echo "$hook_name"
      done | sort | while IFS= read -r hook_name; do
        "''${global_hooks[$hook_name]}" "$@" || exit $?
      done

      # Run local hooks (in alphabetical order)
      for hook_name in "''${!local_hooks[@]}"; do
        echo "$hook_name"
      done | sort | while IFS= read -r hook_name; do
        "''${local_hooks[$hook_name]}" "$@" || exit $?
      done

      exit 0
    '';
  };

  # Symlink prepare-commit-msg to the dispatcher
  home.file.".config/git/hooks/prepare-commit-msg" = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/git/hooks/hook-dispatcher";
  };

  # Lumen-based commit message generation hook
  home.file.".config/git/hooks/prepare-commit-msg.d/lumen-commit-msg" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      set -euo pipefail

      MSG_FILE="$1"
      SOURCE="''${2-}"

      # Skip merge commits
      if [ "''${SOURCE}" = "merge" ]; then
        exit 0
      fi

      # Don't overwrite non-comment content
      if grep -q '^[^#[:space:]]' "$MSG_FILE"; then
        exit 0
      fi

      # Ensure lumen exists
      if ! command -v lumen >/dev/null 2>&1; then
        exit 0
      fi

      # Precompute gitmoji list (best-effort; proceed even if unavailable)
      GITMOJI_LIST="$(gitmoji list 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' || true)"

      SUBJECT=""
      BODY=""

      # Subject line via Lumen draft with gitmoji formatting and additional context
      SUBJECT="$(lumen draft --context "if there are too many changes to document on a single line, then generalize; otherwise summarize all changes. Set output format to <icon-representing-type> <type>[optional scope]: <short summary of all changes>, use gitmoji for icon, one of ''${GITMOJI_LIST}" 2>/dev/null || true)"
      # Keep only the first line and trim trailing whitespace
      SUBJECT="$(printf '%s\n' "$SUBJECT" | sed -e 's/[[:space:]]*$//' | head -n1)"
      # Comment out subject so user must explicitly opt-in
      if [ -n "$SUBJECT" ]; then
        SUBJECT="$(printf '%s\n' "$SUBJECT" | sed 's/^/# /')"
      fi

      # Commit body via Lumen explain over staged diff
      if BODY=$(lumen explain --staged --diff -q "Format your response so it fits well in the body of a git commit, do not include a heading/title" 2>/dev/null); then
        BODY="$(printf '%s\n' "$BODY" | sed -e 's/[[:space:]]*$//')"
        # Extract only the content after the first occurrence of "Done"
        BODY_TRIMMED="$(printf '%s\n' "$BODY" | awk 'found{print} /Done/{found=1; next}')"
        if [ -n "$BODY_TRIMMED" ]; then
          BODY="$BODY_TRIMMED"
        fi
        # Comment out all lines so the user must actively uncomment
        BODY="$(printf '%s\n' "$BODY" | sed 's/^/# /')"
      fi

      # If neither was produced, do nothing
      if [ -z "$SUBJECT$BODY" ]; then
        exit 0
      fi

      COMMENTS=$(grep '^#' "$MSG_FILE" || true)

      # Write message: fully commented subject and body, then original comments
      : > "$MSG_FILE"
      if [ -n "$SUBJECT" ]; then
        printf '%s\n' "$SUBJECT" >> "$MSG_FILE"
      fi
      if [ -n "$BODY" ]; then
        printf '\n%s\n' "$BODY" >> "$MSG_FILE"
      fi
      if [ -n "$COMMENTS" ]; then
        printf '\n%s\n' "$COMMENTS" >> "$MSG_FILE"
      fi

      exit 0
    '';
  };
}
