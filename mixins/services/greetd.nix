{ config, pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      # First VT activation after boot goes straight into river (no login
      # friction). Logging out lands in tuigreet, where any registered
      # wayland session (river, hyprland, ...) can be picked.
      initial_session = {
        command = "${pkgs.river-classic}/bin/river";
        user = "netbrain";
      };
      default_session = {
        command = lib.concatStringsSep " " [
          "${pkgs.tuigreet}/bin/tuigreet"
          "--time"
          "--remember"
          "--remember-user-session"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
        ];
        user = "greeter";
      };
    };
  };
}
