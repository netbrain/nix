{ pkgs, ... }:
{
  imports = builtins.trace "Loading users/netbrain/home/default.nix:" [
    ./home.nix
    ./foot.nix
    ./git.nix
    ./golang.nix
    ./gtk.nix
    ../../../mixins/programs/home/helix.nix
    ./zoxide.nix
    ./stylix.nix
    ./wrappers.nix
  ];
}

