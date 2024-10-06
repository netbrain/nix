{ pkgs, ... }:
{
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.river}/bin/river";
        user = "netbrain";
      };
      default_session = initial_session;
    };
  };
}
