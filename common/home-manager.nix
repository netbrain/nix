{ config, pks, ... }:
let
  home-manager = builtins.fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    ref = "release-23.05";
    rev = "07682fff75d41f18327a871088d20af2710d4744";
  };
in
{
  imports = [ (import "${home-manager}/nixos") ];
}
