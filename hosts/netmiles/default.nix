{ inputs, ... }:

{
  imports =  inputs.nixpkgs.lib.traceSeq "Loading hosts/netmiles/default.nix:" [
     inputs.hardware.nixosModules.lenovo-thinkpad-x1-12th-gen
    ./configuration.nix
    ./hw.nix
    ./powermgmt.nix
    ./gui.nix
  ];
}
