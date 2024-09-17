{
  # To set up Sway using Home Manager, first you must enable Polkit in your nix configuration:
  security.polkit.enable = true;

  # If you are on a laptop, you can set up brightness and volume function keys as follows:
  users.users.netbrain.extraGroups = [ "video" ];
  programs.light.enable = true;
}
