{ config, pkgs, ... }:

{
  # Auto-login loop: greetd starts the kiosk session as netbrain (whose
  # podman store holds the zwift image and all rider volumes); when the
  # session exits, greetd restarts it and the rider chooser in xinitrc
  # comes back up. Admin access via SSH or a spare VT.
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "startx";
        user = "netbrain";
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
