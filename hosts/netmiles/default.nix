{ inputs, ... }:

{
  imports = [
     inputs.hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    ./configuration.nix
    ./hw.nix
    ./powermgmt.nix
    ./gui.nix
    ./lyse-cert.nix
    ./lyse-docker.nix
    ./tailscale.nix
    ./browsers
    ../../mixins/networking/networkmanager.nix
    ../../mixins/virtualisation/libvirt.nix
    ../../mixins/virtualisation/docker.nix
    ../../mixins/programs/steam.nix
    ../../mixins/programs/nm-applet.nix
    ../../mixins/programs/wireshark.nix
    ../../mixins/programs/river.nix
    ../../mixins/services/greetd.nix
    ../../mixins/services/blueman.nix
    ../../mixins/services/fwupd.nix
    ../../secrets/sops.nix
    ../../secrets/lyse-secrets.nix
  ];

  services.ollama = {
  enable = true;
};
}
