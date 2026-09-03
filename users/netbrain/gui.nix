{ pkgs, ... }:

{

  hardware.enableAllFirmware  = true;

  services.xserver.xkb.layout = "no";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    # Prefer the USB condenser mic over other capture devices when plugged in
    # (everything ships with priority.session 2600, so ties are arbitrary).
    wireplumber.extraConfig."51-mic-priority" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "~alsa_input.usb-DCMT_Technology_USB_Condenser_Microphone.*"; }];
          actions.update-props = {
            "priority.session" = 3000;
            "priority.driver" = 3000;
          };
        }
      ];
    };
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
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

  # Kept even though the river mixin also sets this: netbox/netbfg have no
  # other portal config, and flatpak apps rely on portals being present.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
  };

  environment.systemPackages = with pkgs; [
    slack
    teams-for-linux
  ];
}
