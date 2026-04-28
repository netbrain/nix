{ ... }:
{
  # Required for @anthropic-ai/claude-code (npx-installed via npm-package flake):
  # 2.x ships a Bun-bundled ELF that needs /lib64/ld-linux-x86-64.so.2.
  # Only glibc-internal libs are dynamically linked, so no `libraries` list needed.
  programs.nix-ld.enable = true;
}
