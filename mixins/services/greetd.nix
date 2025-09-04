{ pkgs, lib, ... }:
{
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.river-classic}/bin/river";
        user = "netbrain";
      };
      default_session = initial_session;
    };
  };
}
