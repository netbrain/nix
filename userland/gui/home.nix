{ pkgs, ... }:

{

  home.packages = with pkgs; [
    google-chrome
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.goland
    jetbrains.gateway
    jetbrains.rider
    jetbrains.webstorm
    slack
    remmina
    spotify
    element-desktop
  ];
 
}
