{ pkgs, ... }:
{
  
  programs.river-classic = {
    enable = true;
    extraPackages = with pkgs; [
      swaylock
      hyprpicker
      lswt
      tofi
      foot
      pamixer
      pasystray
      playerctl
      brightnessctl
      grim
      slurp
      wl-clipboard
      waybar
      xdg-desktop-portal-wlr # Make screensharing work (https://codeberg.org/river/wiki#why-doesn-t-screensharing-work)
    ];
  };

  xdg.portal = {
    enable = true;
    wlr = {
      enable = true;
    };
  };
}
