{ config, pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = {
      # First VT activation after boot goes straight into hyprland (no login
      # friction). Logging out lands in tuigreet, where any registered
      # wayland session (river, hyprland, ...) can be picked.
      # The wrapper path (not the store path) keeps the cap_sys_nice
      # capability that programs.hyprland sets up via security.wrappers.
      initial_session = {
        command = "${config.security.wrapperDir}/Hyprland";
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
