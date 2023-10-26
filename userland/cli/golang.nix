{ pkgs, ... }:
{
  home.packages = with pkgs; [
    go
    gopls
    gotools
    delve
  ];
}
