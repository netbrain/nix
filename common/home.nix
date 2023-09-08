{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./sway.nix
    ./waybar.nix
    ./alacritty.nix
    ./gtk.nix
    ./mako.nix
    ./neovim.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "netbrain";
    homeDirectory = "/home/netbrain";
    stateVersion = "23.05";
  };

  home.packages = with pkgs; [
    tree
    curl
    stow
    gcc
    gnumake
    iperf
    xdg-utils
    unzip
    google-chrome
    jetbrains.datagrip
    jetbrains.idea-ultimate
    jetbrains.goland
    slack
    teams
    remmina
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.htop.enable = true;
  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.dircolors.enable = true;
  programs.jq.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;
  };

  programs.java.enable = true;

  systemd.user.startServices = "sd-switch";
}
