{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    portalPackage =
      pkgs.xdg-desktop-portal-wlr
      // {
        override = args: pkgs.xdg-desktop-portal-wlr.override (builtins.removeAttrs args ["hyprland"]);
      };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Yaru";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  environment.systemPackages = with pkgs; [
    kitty
    brightnessctl
    hypridle
    hyprlock
    hyprpaper
    hyprpicker
    libnotify
    networkmanagerapplet
    pamixer
    pavucontrol
    slurp
    swappy
    tesseract
    wf-recorder
    wlr-randr
    wlsunset
  ];
}
