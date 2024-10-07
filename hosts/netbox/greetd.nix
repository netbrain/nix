{ config, pkgs, ... }:

{
  # Greetd service configuration
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --user-menu --time --cmd 'startx'";
        user = "greeter";
      };
    };
  };

  # Ensuring correct systemd settings for greetd with Xorg
  systemd.services.greetd.serviceConfig = {
    Type = "idle"; 
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";  # Redirect errors to journal instead of screen
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
  };
}
