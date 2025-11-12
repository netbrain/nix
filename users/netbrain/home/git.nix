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
      # This script enables running git hooks in two modes:
      # 1. Single hook mode: If <hook-name> is an executable file, run it
      # 2. Multiple hook mode: If <hook-name> is a directory, run all executables inside
      #
      # DIRECTORY STRUCTURE:
      #   Single hook mode:
      #     Global: ~/.config/git/hooks/<hook-name>
      #     Common: .git/hooks/<hook-name> (shared across worktrees)
      #     Local:  .git/worktrees/<name>/hooks/<hook-name> (worktree-specific)
      #
      #   Multiple hook mode:
      #     Global: ~/.config/git/hooks/<hook-name>/ (directory with multiple scripts)
      #     Common: .git/hooks/<hook-name>/ (shared across worktrees)
      #     Local:  .git/worktrees/<name>/hooks/<hook-name>/ (worktree-specific)
      #
      #   Legacy .d directory mode (still supported):
      #     Global: ~/.config/git/hooks/<hook-name>.d/
      #     Common: .git/hooks/<hook-name>.d/
      #     Local:  .git/worktrees/<name>/hooks/<hook-name>.d/
      #
      # EXECUTION ORDER:
      #   1. Global hooks run first (alphabetically if directory)
      #   2. Common hooks run second (shared across worktrees, alphabetically if directory)
      #   3. Local hooks run third (worktree-specific, alphabetically if directory)
      #   4. If a local/common hook has the same filename as a global hook, the global hook is skipped
      #   5. If a local hook has the same filename as a common hook, the common hook is skipped
      #   6. If .skip-global marker exists, all global hooks are skipped
      #
      # USAGE:
      #   Single global hook:
      #     Create ~/.config/git/hooks/<hook-name> as an executable file
      #     Example: ~/.config/git/hooks/prepare-commit-msg
      #
      #   Multiple global hooks:
      #     Create ~/.config/git/hooks/<hook-name>/ as a directory
      #     Add executable files inside
      #     Example: ~/.config/git/hooks/prepare-commit-msg/lumen-commit-msg
      #
      #   Single local hook:
      #     Create .git/hooks/<hook-name> as an executable file
      #
      #   Multiple local hooks:
      #     Create .git/hooks/<hook-name>/ as a directory
      #     Example: .git/hooks/prepare-commit-msg/custom-validation
      #
      #   Override specific global hook:
      #     Create a local hook with the same filename as the global hook
      #     Example: .git/hooks/prepare-commit-msg/lumen-commit-msg overrides global lumen-commit-msg
      #
      #   Skip all global hooks:
      #     Create .git/hooks/<hook-name>/.skip-global (empty file)
      #     Example: touch .git/hooks/prepare-commit-msg/.skip-global
      #     Works with both directory and .d directory modes
      #
      # ERROR HANDLING:
      #   If any hook exits with non-zero status, execution stops and git aborts the operation
      #
      # NOTES:
      #   - Hooks must be executable (chmod +x)
      #   - Both regular files and symlinks are supported
      #   - Non-executable files are silently skipped
      #   - Alphabetical ordering allows numeric prefixes for explicit ordering (e.g., 10-first, 20-second)
      #   - The .d suffix is optional but supported for backward compatibility
      #   - stdin is captured and replayed to each hook (important for pre-push, post-rewrite, etc.)

      # Determine which hook was called (e.g., prepare-commit-msg, pre-commit, etc.)
      HOOK_NAME="$(basename "$0")"

      # Get the git repository directories
      # For worktrees, --git-dir returns the worktree-specific dir, --git-common-dir returns shared dir
      GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || echo "")"
      GIT_COMMON_DIR="$(git rev-parse --git-common-dir 2>/dev/null || echo "$GIT_DIR")"

      # Define hook paths
      GLOBAL_HOOK_BASE="${config.home.homeDirectory}/.config/git/hooks/''${HOOK_NAME}"
      LOCAL_HOOK_BASE="''${GIT_DIR}/hooks/''${HOOK_NAME}"
      COMMON_HOOK_BASE="''${GIT_COMMON_DIR}/hooks/''${HOOK_NAME}"

      # Capture stdin to a temporary file for hooks that consume it (e.g., pre-push, post-rewrite)
      # This allows multiple hooks to read the same stdin data
      STDIN_FILE=""
      if [ -t 0 ]; then
        # stdin is a terminal (interactive), no need to capture
        :
      else
        # stdin has data, capture it to a temporary file
        STDIN_FILE="$(mktemp)"
        cat > "$STDIN_FILE"
        trap 'rm -f "$STDIN_FILE"' EXIT
      fi

      # Collect all hook files
      declare -A global_hooks
      declare -A common_hooks
      declare -A local_hooks

      # Function to scan a hook location (supports file, directory, or .d directory)
      scan_hooks() {
        local base_path="$1"
        local -n hooks_array="$2"  # nameref to associate array

        # Check .d directory first (legacy support)
        if [ -d "''${base_path}.d" ]; then
          while IFS= read -r -d "" hook; do
            [ -x "$hook" ] || continue
            hook_basename="$(basename "$hook")"
            hooks_array["$hook_basename"]="$hook"
          done < <(find "''${base_path}.d" -maxdepth 1 \( -type f -o -type l \) -print0 | sort -z)
        # Check if it's a directory (without .d)
        elif [ -d "$base_path" ]; then
          while IFS= read -r -d "" hook; do
            [ -x "$hook" ] || continue
            hook_basename="$(basename "$hook")"
            hooks_array["$hook_basename"]="$hook"
          done < <(find "$base_path" -maxdepth 1 \( -type f -o -type l \) -print0 | sort -z)
        # For single file mode: only scan if it exists in .git/hooks (local), not global
        # This prevents the dispatcher from trying to execute itself
        fi
      }

      # Scan global hooks (skip single file mode for global to avoid recursion)
      scan_hooks "$GLOBAL_HOOK_BASE" global_hooks

      # Scan common hooks (shared across worktrees) if different from local
      if [ "$GIT_COMMON_DIR" != "$GIT_DIR" ]; then
        scan_hooks "$COMMON_HOOK_BASE" common_hooks
        # Also check for single file in common dir
        if [ -x "$COMMON_HOOK_BASE" ] && [ -f "$COMMON_HOOK_BASE" ] && [ ! -L "$COMMON_HOOK_BASE" ]; then
          hook_basename="$(basename "$COMMON_HOOK_BASE")"
          common_hooks["$hook_basename"]="$COMMON_HOOK_BASE"
        fi
      fi

      # Scan worktree-specific local hooks
      scan_hooks "$LOCAL_HOOK_BASE" local_hooks

      # Also check if local hook exists as a single file
      if [ -x "$LOCAL_HOOK_BASE" ] && [ -f "$LOCAL_HOOK_BASE" ] && [ ! -L "$LOCAL_HOOK_BASE" ]; then
        hook_basename="$(basename "$LOCAL_HOOK_BASE")"
        local_hooks["$hook_basename"]="$LOCAL_HOOK_BASE"
      fi

      # Check if .skip-global marker exists to skip all global hooks
      SKIP_GLOBAL=false
      if [ -f "''${LOCAL_HOOK_BASE}/.skip-global" ] || [ -f "''${LOCAL_HOOK_BASE}.d/.skip-global" ] || \
         [ -f "''${COMMON_HOOK_BASE}/.skip-global" ] || [ -f "''${COMMON_HOOK_BASE}.d/.skip-global" ]; then
        SKIP_GLOBAL=true
      fi

      # Remove overridden hooks
      # Local hooks override common hooks, common hooks override global hooks
      if [ "$SKIP_GLOBAL" = true ]; then
        # Skip all global hooks
        global_hooks=()
      else
        # Common hooks override global hooks with matching names
        for hook_name in "''${!common_hooks[@]}"; do
          unset global_hooks["$hook_name"]
        done
        # Local hooks override both common and global hooks with matching names
        for hook_name in "''${!local_hooks[@]}"; do
          unset global_hooks["$hook_name"]
          unset common_hooks["$hook_name"]
        done
      fi

      # Function to run a hook with proper stdin handling
      run_hook() {
        local hook_path="$1"
        shift
        if [ -n "$STDIN_FILE" ]; then
          # Pass captured stdin to the hook
          "$hook_path" "$@" < "$STDIN_FILE" || return $?
        else
          # No stdin to pass
          "$hook_path" "$@" || return $?
        fi
      }

      # Run hooks in order: global -> common -> local (alphabetically within each)

      # Run global hooks (in alphabetical order, excluding overridden ones)
      for hook_name in "''${!global_hooks[@]}"; do
        echo "$hook_name"
      done | sort | while IFS= read -r hook_name; do
        run_hook "''${global_hooks[$hook_name]}" "$@" || exit $?
      done

      # Run common hooks (shared across worktrees)
      for hook_name in "''${!common_hooks[@]}"; do
        echo "$hook_name"
      done | sort | while IFS= read -r hook_name; do
        run_hook "''${common_hooks[$hook_name]}" "$@" || exit $?
      done

      # Run local worktree-specific hooks
      for hook_name in "''${!local_hooks[@]}"; do
        echo "$hook_name"
      done | sort | while IFS= read -r hook_name; do
        run_hook "''${local_hooks[$hook_name]}" "$@" || exit $?
      done

      exit 0
    '';
  };

  # Symlink common git hooks to the dispatcher
  # Note: We reference the dispatcher file directly so all hooks share the same code
  home.file.".config/git/hooks/pre-commit".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/prepare-commit-msg".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/commit-msg".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/post-commit".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/pre-push".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/post-checkout".source = config.home.file.".config/git/hooks/hook-dispatcher".source;
  home.file.".config/git/hooks/post-merge".source = config.home.file.".config/git/hooks/hook-dispatcher".source;

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
