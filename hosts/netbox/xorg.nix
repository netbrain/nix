
{ config, pkgs, ... }:

{
  nixpkgs.config.nvidia.acceptLicense = true;
  
  virtualisation = {
    podman = {
      enable = true;
      enableNvidia = true;
    };
  };

  hardware.graphics.enable32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = false; #true
  hardware.nvidia-container-toolkit.enable = true;
  hardware.nvidia.open = false;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_390;

  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" "nvidiaLegacy390" ];
    displayManager.startx.enable = true;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    xorg.xorgserver
    xorg.xf86inputevdev
    xorg.xhost
    openbox
  ];

  # Environment variables for Zwift
  environment.variables = {
    ZWIFT_FG = "1";
  };

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
    xterm -e 'zwift --replace' &

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
  

    # Wait for Openbox to finish
    wait $OPENBOX_PID

    # Clean exit and return to login manager (greetd, for example)
    logout
  '';

}
