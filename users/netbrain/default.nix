{
  
  imports = builtins.trace "Loading users/netbrain/default.nix" [
    ./greetd.nix
    ./gui.nix
    ./libvirt.nix
    ./networkmanager.nix
    ./security.nix
    ./services.nix
    ./sops.nix
    ./steam.nix
    ./system.nix
    ./user.nix
    ./virtualisation.nix
    ./wireshark.nix
  ];
}
