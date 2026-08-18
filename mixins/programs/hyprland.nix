{ pkgs, ... }:
{
  # Registers the wayland session and wires up xdg-desktop-portal-hyprland
  programs.hyprland.enable = true;

  # hyprlock is installed via home-manager; without a PAM entry it cannot
  # authenticate the unlock
  security.pam.services.hyprlock = { };

  # With two portal backends installed (wlr for river, hyprland's own),
  # scope wlr to the river session so they don't fight over interfaces.
  # The hyprland portal ships its own portals.conf. gtk covers file
  # choosers, which neither compositor portal implements.
  xdg.portal = {
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    config = {
      common.default = [ "*" ];
      river.default = [ "wlr" "gtk" ];
    };
  };
}
