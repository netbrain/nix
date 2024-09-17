{ inputs,... }:
{
  imports =  inputs.nixpkgs.lib.traceSeq "Loading hosts/netmiles/home/default.nix:" [
    ./kanshi.nix
  ];
}
