{ pkgs, ... }:

{
  imports = [
    ./users.nix
    ./sudo.nix
    ./docker.nix
    ./greetd.nix
    ./home-manager.nix
  ];

  nix.settings.trusted-users = [ "root" "netbrain" ];
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = "experimental-features = nix-command flakes";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "no";
    #useXkbConfig = true; # use xkbOptions in tty.
  };

  services.tailscale.enable = true;
  services.flatpak.enable = true;
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  users.users."netbrain".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCuYnieATL5o4WCdGUA+NvZ36rcWasKoQ0wUAsJiHSf95mRmy4ceG1p1LO+VQ4YnXFnApokejIwNnGYAge00dZ3Fl3d1LsjegnigD6/w0GdrmxhfL4UzhRw6nFJGVtw5oiVfcJap1nl9iCtUAsqKuzPA7itR0YfHwsu06AyIVf9h8viL8cYidx5SBHiugywLT/wBSOGLqjvCIvyXHn1PiYSrP9GzLMpfh4cx8YclsaJACWjjt20j7InecVVDULQrYRZnQxZWJrNWtWbSLcWBUjFktN4piSw19xZd9L7SqcONeAeIayA0GowE7eR6pX0HtH5GUNzloQsNq5JOPmJbz+D netbrain"
  ];

  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.netbrain = import ./home.nix;

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
      nix-index
      pciutils
      nmap
      netcat
      tailscale
    ];
  };

  networking = {
    enableIPv6 = false;
    firewall.enable = false;
  };

  system.stateVersion = "23.05";
}

