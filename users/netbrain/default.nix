{
  imports = [
    ./gui.nix
    ./security.nix
    ./memory.nix
    ../../mixins/services/openssh.nix
    ../../mixins/services/flatpak
    ../../mixins/programs/zwift.nix
    ./system.nix
    ./user.nix
  ];
}
