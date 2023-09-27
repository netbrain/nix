{ pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./libvirt.nix
    ./bluetooth.nix
  ];

  sound.enable = true;
  hardware.enableAllFirmware  = true;

  services.xserver.layout = "no";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  programs.sway = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      wf-recorder
      mako
      slurp
      grim
      alacritty
      tofi
      wlr-randr
      wdisplays
      waybar
      pavucontrol
      pulseaudio
      playerctl
      networkmanagerapplet
      networkmanager-sstp
    ];
  };

  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  fonts = {
    fonts = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      nerdfonts
    ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}

