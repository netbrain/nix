{ pkgs, ... }:
{
  stylix = {
    enable = true;
    image = ./wallpaper/unL2Hw4-B31E1.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    autoEnable = true;
    opacity = {
      terminal = 0.8;
    };
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.noto;
        name = "NotoSansM Nerd Font";
      };
    };
  };
}
