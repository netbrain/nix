{ pkgs, ... }:
{
  imports = builtins.trace "Loading users/netbrain/home/default.nix:" [
    ./home.nix
    ./foot.nix
    ./git.nix
    ./golang.nix
    ./gtk.nix
    ./helix.nix
    ./mako.nix
    ./maven.nix
    ./sway.nix
    ./waybar.nix
    ./zoxide.nix
    ./zwift.nix
  ];

  home.packages = with pkgs; [
    google-chrome
#    jetbrains.datagrip
#    jetbrains.idea-ultimate
#    jetbrains.goland
#    jetbrains.rider
#    jetbrains.webstorm
    slack
    remmina
    spotify
    element-desktop
  ];
}

