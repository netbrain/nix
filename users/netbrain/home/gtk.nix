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
    # Papirus-based, so app icons resolve (waybar hyprland/window icon,
    # launchers); gruvbox-dark-icons-gtk only covers folders/places
    iconTheme = {
      package = pkgs.gruvbox-plus-icons;
      name = "Gruvbox-Plus-Dark";
    };
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
