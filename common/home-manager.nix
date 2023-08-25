{ config, pks, ... }:
let
  home-manager = builtins.fetchTarball {
    url = "https://github.com/nix-community/home-manager/archive/release-23.05.tar.gz";
    sha256 = "17bhps716gn3g49n959ks9ympmg5808l3c5c06fx88b6d2qax57y";
  };
in 
{
  imports = [ (import "${home-manager}/nixos") ];
}
