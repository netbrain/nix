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
    '';
  };

  # Global prepare-commit-msg hook that drafts a subject via Lumen and adds a concise body via Lumen explain
  home.file.".config/git/hooks/prepare-commit-msg" = {
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
      if BODY=$(lumen explain --staged --diff -q "Create a summary of all changes, focus on the most important ones, limit your output to a sensible size, prefer compact over verbose, render as a single list, if scope is present, wrap in parenthesis. Use one of the following types: 
- docs: Documentation only changes
- style: Changes that do not affect the meaning of the code
- refactor: A code change that neither fixes a bug nor adds a feature
- perf: A code change that improves performance
- test: Adding missing tests or correcting existing tests
- build: Changes that affect the build system or external dependencies
- ci: Changes to our CI configuration files and scripts
- chore: Other changes that don't modify src or test files
- revert: Reverts a previous commit
- feat: A new feature
- fix: A bug fix

For the icon, pick one from: ''${GITMOJI_LIST}.
Every list item must be rendered exactly as: 
'* <icon> <type>[optional scope]: <summarized change description>'" 2>/dev/null); then
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
