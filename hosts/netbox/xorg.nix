
{ pkgs, ... }:

{
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    xorg.xorgserver
    xorg.xf86inputevdev
    xorg.xhost
    xorg.xrefresh
    openbox
    stremio
    wmctrl
    spotify
    firefox
  ];

  # Environment variables for Zwift
  environment.variables = {
    ZWIFT_FG = "1";
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
    # Start the window manager (Openbox)
    openbox &

    # Store Openbox's process ID separately
    OPENBOX_PID=$!

    # Prevent the screen from turning off
    xset -dpms
    setterm -blank 0 -powerdown 0
    xset s off

    # Allow local clients to connect to X server
    xhost +local:

    # Start Zwift (run in the background)
    xterm -bg black -fg white -e 'zwift --replace' &

    # Start stremio
    stremio &
    
    # Retry Bluetooth connection setup and connection in the background
    (
      while true; do
        bluetoothctl power on
        bluetoothctl agent on
        bluetoothctl pair 41:42:C4:33:F3:8A
        bluetoothctl trust 41:42:C4:33:F3:8A
        if bluetoothctl connect 41:42:C4:33:F3:8A; then
          echo "Bluetooth connected successfully."
          break
        else
          echo "Bluetooth connection failed, retrying in 5 seconds..."
          sleep 5
        fi
      done
    ) &

    sleep 3 && xrefresh 

    # Position windows
    STREMIO_WINDOW=$(wmctrl -l | grep -i stremio | cut -f 1 -d ' ')
    wmctrl -ir $STREMIO_WINDOW -e 0,0,1080,-1,-1
    wmctrl -ir $STREMIO_WINDOW -b add,maximized_vert,maximized_horz

    ZWIFT_WINDOW=$(wmctrl -l | grep Zwift | cut -f 1 -d ' ')
    wmctrl -ir $ZWIFT_WINDOW -b add,maximized_vert, maximized_horz
    
    # Wait for Openbox to finish
    wait $OPENBOX_PID

    # Clean exit and return to login manager (greetd, for example)
    logout
  '';

}
