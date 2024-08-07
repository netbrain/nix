{ pkgs, ... }:

{

  hardware.enableAllFirmware  = true;

  services.xserver.xkb.layout = "no";

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
      tofi
      wlr-randr
      wdisplays
      pavucontrol
      pulseaudio
      playerctl
      discord
      waypipe
      (waybar.override {
        wireplumberSupport = false;
      })
    ];
  };


  systemd.services.NetworkManager-wait-online.enable = false;
  programs.nm-applet.enable = true;

  fonts = {
    packages = with pkgs; [
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

