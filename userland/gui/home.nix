{ pkgs, ... }:

{
  imports = [
    ../cli/home.nix
    #./alacritty.nix
    ./foot.nix
    ./mako.nix
    ./sway.nix
    ./waybar.nix
    ./gtk.nix
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

