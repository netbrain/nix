{ pkgs, ... }:

{
  console = {
    font = "Lat2-Terminus16";
    keyMap = "no";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Oslo";

  environment = {
    shells = [ pkgs.bash ];
    variables = {
      EDITOR = "vim";
    };
    systemPackages = with pkgs; [
      vim
      wget
      curl
      dig
      bc
    ];
  };

  networking = {
    enableIPv6 = false;
    firewall.enable = false;
  };

  system.stateVersion = "24.05";
}
