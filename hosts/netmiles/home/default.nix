{ pkgs, ... }:
{
  imports = [
    ./river.nix
    ./kanshi.nix
    ./pwd-lyse-maven-update.nix
    ./waybar.nix
    ./helix.nix
    ../../../mixins/programs/home/helix.nix
    ../../../mixins/services/home/mako.nix
  ];

  home.packages = with pkgs; [
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.goland
    jetbrains.rider
    jetbrains.webstorm
    remmina
    spotify
    pavucontrol
    wdisplays
  ];
}
