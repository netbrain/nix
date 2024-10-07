{ inputs, ... }:

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
}
