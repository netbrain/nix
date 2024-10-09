{	
  # bluetooth
  services.pipewire.wireplumber.extraConfig.bluetoothEnhancements = {
    "monitor.bluez.seat-monitoring" = "disabled";
  };
  
  hardware.bluetooth.enable = true; 
  hardware.bluetooth.settings = {
    General = {
      Enable = "Source,Sink,Media,Socket";
    };
  };
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
