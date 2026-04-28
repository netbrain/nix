{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    go
    gopls
    (lib.lowPrio gotools)
    delve
  ];
}
