{
  imports = [
    ./gui.nix
    ./security.nix
    ./memory.nix
    ../../mixins/services/openssh.nix
    ../../mixins/services/flatpak
    ../../mixins/programs/zwift.nix
    ../../mixins/programs/nix-ld.nix
    ./system.nix
    ./user.nix
  ];
}
