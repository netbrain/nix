{ pkgs, ... }:

{
  imports = [
    ./git.nix
    ./sway.nix
    ./waybar.nix
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
    spotify
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    NIXPKGS_ALLOW_UNFREE = 1;
  };

  programs.htop.enable = true;
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
    eval "$(direnv hook bash)"
    '';
    shellAliases = {
      ".." = "cd .." ;
      nrs = "sudo nixos-rebuild switch --flake path:/etc/nixos";
      ngc = "sudo sh -c 'nix-env --delete-generations old && nix-store --gc && nix-collect-garbage -d'";
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.foot = import ./foot.nix;
  programs.dircolors.enable = true;
  programs.jq.enable = true;

  programs.starship.enable = true;
  programs.starship.settings.add_newline = true;

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

  programs.lf.enable = true;

  systemd.user.startServices = "sd-switch";
}
