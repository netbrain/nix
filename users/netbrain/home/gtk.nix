{ pkgs, ... }:
{
  gtk = {
    enable = true;
    # Note: gtk.gtk4.theme is set by stylix (modules/gtk/hm.nix) to
    # config.gtk.theme; don't define it here or it conflicts.
    #theme = {
    #  package = pkgs.gruvbox-dark-gtk;
    #  name = "gruvbox-dark";
    #};
#    iconTheme = {
#      package = pkgs.gruvbox-dark-icons-gtk;
#      name = "gruvbox-dark";
#    };
    #gtk2.extraConfig = ''
    #  gtk-cursor-theme-size = 16
    #  gtk-cursor-theme-name = "capitaine-cursors"
    #'';
    #gtk3.extraConfig = {
    #  gtk-cursor-theme-size = 16;
    #  gtk-cursor-theme-name = "capitaine-cursors";
    #};
  };
  home.pointerCursor = {
    name = "capitaine-cursors";
    package = pkgs.capitaine-cursors;
  };
}
