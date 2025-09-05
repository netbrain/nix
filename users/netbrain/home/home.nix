{ pkgs, inputs, config, ... }:

{
  imports = [
    ../../../secrets/config.nix
  ];

  nixpkgs = {
    config = {
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
    };
    overlays = [
      (final: prev: {
        # Expose mnu (default aggregates mnu-bw, mnu-run, mnu-drun) and individual binaries
        mnu     = inputs.mnu.packages.${final.stdenv.hostPlatform.system}.default;
        mnu-bw  = inputs.mnu.packages.${final.stdenv.hostPlatform.system}."mnu-bw";
        mnu-run = inputs.mnu.packages.${final.stdenv.hostPlatform.system}."mnu-run";
        mnu-drun= inputs.mnu.packages.${final.stdenv.hostPlatform.system}."mnu-drun";
        # Expose lumen (default package)
        lumen   = inputs.lumen.packages.${final.stdenv.hostPlatform.system}.default;
      })
    ];
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
    tig
    (pkgs.warp-terminal.override { waylandSupport = true; })
    bitwarden-cli
    mnu
    lumen
    #(bitwarden-cli.overrideAttrs (oldAttrs: rec {
    #  dontCheckForBrokenSymlinks = true;
    #}))
    #(lldb.overrideAttrs (oldAttrs: rec {
    #  dontCheckForBrokenSymlinks = true;
    #}))
    moonlight-qt
    ripgrep
    fzf
    rip2
    gitmoji-cli
    (inputs.npm-package.lib.${system}.npmPackage {
      name = "claude";
      packageName = "@anthropic-ai/claude-code";
    })
    (inputs.npm-package.lib.${system}.npmPackage {
      name = "codex";
      packageName = "@openai/codex";
    })
    (inputs.npm-package.lib.${system}.npmPackage {
      name = "gemini";
      packageName = "@google/gemini-cli";
    })
  ];

  services.flatpak.packages = [
      { appId = "org.mozilla.Thunderbird"; origin = "flathub-beta";  }
  ];

  services.flatpak.remotes = [{
    name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
  }];

  services.flatpak.overrides = {
    global = {
      # Force Wayland by default
      Context.sockets = ["wayland" "!x11" "!fallback-x11"];

      Environment = {
        # Fix un-themed cursor in some Wayland apps
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
      };
    };
  };

  services.flatpak.update.onActivation = true;

  sops.secrets = {
    "openai/key" = {};
    "gemini/key" = {};
  };

  sops.templates."secretSessionVariables".content = ''
   export OPENAI_API_KEY='${config.sops.placeholder."openai/key"}'
   #export GEMINI_API_KEY='${config.sops.placeholder."gemini/key"}'
  '';

  # Lumen configuration file with OpenAI provider and API key from sops
  sops.templates."lumen.config.json" = {
    path = "/home/netbrain/.config/lumen/lumen.config.json";
    content = ''
      {
        "provider": "openai",
        "apiKey": "${config.sops.placeholder."openai/key"}",
        "model": "gpt-4o-mini"
      }
    '';
  };


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

    # Source sops secrets if the file exists
    # The actual path to the template file is available via config.sops.templates."secretSessionVariables".path
    sops_vars_file="${config.sops.templates."secretSessionVariables".path}"
    if [ -f "$sops_vars_file" ]; then
      source "$sops_vars_file"
    fi
       
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
