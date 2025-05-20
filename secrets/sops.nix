{ pkgs, inputs, config, ... }:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    ./config.nix
  ];
}
