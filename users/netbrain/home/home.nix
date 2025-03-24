{ pkgs, inputs, ... }:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
  };

  home = {
    username = "netbrain";
    homeDirectory = "/home/netbrain";
    stateVersion = "24.05";
  };

  home.packages = with pkgs; [
    sops
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
    file
    iotop
    tailscale
    bitwarden-cli
    #(bitwarden-cli.overrideAttrs (oldAttrs: rec {
    #  dontCheckForBrokenSymlinks = true;
    #}))
    #(lldb.overrideAttrs (oldAttrs: rec {
    #  dontCheckForBrokenSymlinks = true;
    #}))
    moonlight-qt
    ripgrep
    rip2
    (inputs.npm-package.lib.${system}.npmPackage {
      name = "claude";
      packageName = "@anthropic-ai/claude-code";
    })
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    NIXPKGS_ALLOW_UNFREE = 1;
    PATH = "$PATH:$HOME/.local/bin";
  };

  programs.htop.enable = true;

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
       
    inbg(){
      nohup "$@" &>/dev/null & disown
    }

    #Altibox
    aibencrypt() {
      if [ $# -eq 0 ] || [ $1 = "help" ]; then
        echo "Usage: aibencrypt [environment] [key] [value]"
        return
      fi
      docker run -ti --rm nexus.altibox.net:8086/aib/init-puppet secret $1 block $2 $3
    }
    
    export TERM="xterm"
    
    # rip shell completion
    source <(rip completions bash)
    '';
    
    shellAliases = {
      rm = "echo Use 'rip' instead of rm.";
      rmdir = "echo Use 'rip' instead of rmdir.";
      vi = "hx";
      vim = "hx";
      ".." = "cd .." ;
      nrs = "sudo nixos-rebuild switch --flake path:/etc/nixos";
      nrt = "sudo nixos-rebuild test --flake path:/etc/nixos";
      ngc = "sudo sh -c 'nix-env --delete-generations old && nix-store --gc && nix-collect-garbage -d'";
      ns = "nix --extra-experimental-features \"nix-command flakes\" search nixpkgs";
      goland = "inbg goland";
      rider = "inbg rider";
      webstorm = "inbg webstorm";
      idea-ultimate = "inbg idea-ultimate";
      pwd-lyse-vpn = "read -s -p 'Master password:' pwd; echo -n $(echo $pwd | bw get password 4fab525d-7b81-4421-8813-b084006afed4)$(echo $pwd | bw get totp 4fab525d-7b81-4421-8813-b084006afed4) | wl-copy";      
      pwd-lyse-otp = "bw get totp 4fab525d-7b81-4421-8813-b084006afed4 | wl-copy";
      pwd-lyse-c2a = "bw get password 3d4e37ea-adc9-4733-895f-b05f00ac02e8 | wl-copy";
      pwd-lyse-ipa = "bw get password 4fab525d-7b81-4421-8813-b084006afed4 | wl-copy";
      vpn-lyse = "pwd-lyse-vpn && wl-paste | xargs echo vpn.secrets.password:| nmcli c up Lyse passwd-file /dev/fd/0";
      har-to-k6="docker run -i --rm -w /data --entrypoint node -v \$(pwd):/data grafana/har-to-k6:latest /converter/bin/har-to-k6.js -s --";
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
