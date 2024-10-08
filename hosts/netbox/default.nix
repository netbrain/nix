{ inputs, pkgs, ... }:

{
  imports = [
    inputs.hardware.nixosModules.common-pc
    inputs.hardware.nixosModules.common-pc-ssd
    inputs.hardware.nixosModules.common-cpu-intel-cpu-only
    ./configuration.nix
    ./disko
    ./users.nix
    ./xorg.nix
    ./greetd.nix
    ../../mixins/programs/zwift.nix
  ];

  services.udev.extraRules = ''
    KERNEL=="tty[0-9]*", GROUP="tty", MODE="0660"
  '';

  # needed for home-manager?
  programs.dconf.enable = true;

  # sound & bluetooth
security.rtkit.enable = true;
services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
};
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
