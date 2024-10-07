{ pkgs, ... }:
{
  imports = [
    ./river.nix
    ./kanshi.nix
    ./pwd-lyse-maven-update.nix
    ../../../mixins/programs/home/helix.nix
  ];

  home.packages = with pkgs; [
    brave
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.goland
    jetbrains.rider
    jetbrains.webstorm
    slack
    remmina
    spotify
    element-desktop
  ];
}
