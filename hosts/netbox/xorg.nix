
{ pkgs, ... }:

let
  # Kiosk session loop: riced rofi chooser -> launch rider(s)/media -> re-show
  # the chooser when the launched app exits (never leaves an empty screen).
  kioskSession = pkgs.writeShellScript "zwift-kiosk" (builtins.readFile ./kiosk-session.sh);
in
{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    xorg-server
    xf86-input-evdev
    xhost
    xrefresh
    openbox
    rofi
    dunst
    libnotify
    stremio-linux-shell
    wmctrl
    spotify
    firefox
  ];

  # Emoji rendering for the rofi/dunst kiosk UI (hearts in the greeting).
  fonts.packages = [ pkgs.noto-fonts-color-emoji ];

  programs.zwift = {
    # Run zwift attached so the container blocks the launching xterm until the
    # game is closed; the kiosk loop waits on that to re-show the chooser.
    zwiftFg = true;
    # Weak GPU: replace all graphics profiles with ~/.config/zwift/graphics.txt
    # (managed by home-manager) and force 720p game resolution
    zwiftOverrideGraphics = true;
    zwiftOverrideResolution = "1280x720";
  };

  services.xserver.config = ''
    Section "ServerLayout"
      Identifier     "Layout0"
      Screen      0  "Screen0" 0 0
      Option         "Xinerama" "0"
    EndSection

    Section "Monitor"
      # HorizSync source: edid, VertRefresh source: edid
      Identifier     "Monitor0"
      VendorName     "Unknown"
      ModelName      "DELL U2412M"
      HorizSync       30.0 - 83.0
      VertRefresh     50.0 - 61.0
      Option         "DPMS"
    EndSection

    Section "Device"
      Identifier     "Device0"
      Driver         "nvidia"
      VendorName     "NVIDIA Corporation"
      BoardName      "GeForce GTX 560 Ti"
    EndSection

    Section "Screen"
      Identifier     "Screen0"
      Device         "Device0"
      Monitor        "Monitor0"
      DefaultDepth    24
      Option         "Stereo" "0"
      Option         "nvidiaXineramaInfoOrder" "DFP-1"
      Option         "metamodes" "DVI-I-2: nvidia-auto-select +0+1080 {Rotation=180}, HDMI-0: nvidia-auto-select +0+0"
      Option         "SLI" "Off"
      Option         "MultiGPU" "Off"
      Option         "BaseMosaic" "off"
      SubSection     "Display"
          Depth       24
      EndSubSection
    EndSection
  '';

  # Writing the .xinitrc file
  environment.etc."X11/xinit/xinitrc".text = ''
    #!/bin/sh
    # Start the window manager (openbox); it runs the whole session.
    openbox &
    OPENBOX_PID=$!

    # Prevent the screen from turning off
    xset -dpms
    setterm -blank 0 -powerdown 0
    xset s off

    # Allow local clients to connect to X server
    xhost +local:

    # Notification daemon (for the greeting popup)
    dunst &

    # (Bluetooth headset reconnection is handled by the bt-headset-autoconnect
    # systemd service, independent of this X session.)

    # Rider/media chooser loop
    ${kioskSession} &

    # Wait for openbox to finish, then return to the login manager
    wait $OPENBOX_PID
    logout
  '';

}
