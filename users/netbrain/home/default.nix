{ pkgs, ... }:
{
  imports = builtins.trace "Loading users/netbrain/home/default.nix:" [
    ./home.nix
    ./foot.nix
    ./git.nix
    ./golang.nix
    ./gtk.nix
    ../../../mixins/programs/home/helix.nix
    ./mako.nix
    #./sway.nix
    ./waybar.nix
    ./zoxide.nix
    ./river.nix
    #./hyprland.nix
    ./stylix.nix
  ];

  #home.packages = with pkgs; [
    #google-chrome
    #brave
    #jetbrains.datagrip
    #jetbrains.idea-ultimate
    #jetbrains.goland
    #jetbrains.rider
    #jetbrains.webstorm
    #slack
    #remmina
    #spotify
    #element-desktop
    #lswt
  #];
}

