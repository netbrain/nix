{ pkgs, ... }:
{
  
  programs.river = {
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
    ];
  };
}
