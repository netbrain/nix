{ pkgs, ... }:

{

  hardware.enableAllFirmware  = true;

  services.xserver.xkb.layout = "no";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      mplus-outline-fonts.githubRelease
      dina-font
      proggyfonts
      font-awesome
      nerd-fonts.zed-mono
      nerd-fonts.victor-mono
      nerd-fonts.ubuntu-sans
      nerd-fonts.ubuntu-mono
      nerd-fonts.noto
      nerd-fonts.inconsolata
    ];
  };

  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };
}
