{ pkgs, ... }:

{

  imports = [
    ./git.nix
#    ./neovim.nix
    ./syncthing.nix
    ./helix.nix
    ./golang.nix
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
    nmap
    wget
    netcat
    pciutils
    curl
    stow
    gcc
    gnumake
    iperf
    xdg-utils
    unzip
    tailscale
    bitwarden-cli
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    NIXPKGS_ALLOW_UNFREE = 1;
    PATH = "$PATH:$HOME/.local/bin";
  };

  programs.htop.enable = true;
  programs.home-manager.enable = true;

  programs.bash = {
    enable = true;
    bashrcExtra = ''
    eval "$(direnv hook bash)"
    
    inbg(){
      nohup "$@" &>/dev/null & disown
    }
    '';
    shellAliases = {
      vi = "hx";
      vim = "hx";
      ".." = "cd .." ;
      nrs = "sudo nixos-rebuild switch --flake path:/etc/nixos";
      ngc = "sudo sh -c 'nix-env --delete-generations old && nix-store --gc && nix-collect-garbage -d'";
      goland = "inbg goland";
      rider = "inbg rider";
      webstorm = "inbg webstorm";
      idea-ultimate = "inbg idea-ultimate";
      gateway = "inbg gateway";
    };
  };

  # Unclutter your .profile
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  # CLI JSON processor
  programs.jq.enable = true;

  # Starship
  programs.starship.enable = true;
  programs.starship.settings.add_newline = true;

  # Java
  programs.java.enable = true;

  # Terminal file manager
  programs.lf.enable = true;

  systemd.user.startServices = "sd-switch";
}
