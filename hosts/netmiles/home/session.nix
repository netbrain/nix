{ pkgs, ... }:
{
  # Session services shared by river and hyprland. Everything hangs off
  # graphical-session.target, which both compositors' HM systemd
  # integrations bind to; the applets pull in tray.target, which starts
  # waybar as the tray provider.
  services.pasystray.enable = true;
  services.blueman-applet.enable = true;

  # Previously spawned from river's init; as a unit it works in both
  # sessions and gets restarted if it dies.
  # Clipboard history for the SUPER+V picker (hyprland); harmless under
  # river, where the history simply accumulates too.
  systemd.user.services.cliphist-text = {
    Unit = {
      Description = "cliphist text watcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.cliphist-image = {
    Unit = {
      Description = "cliphist image watcher";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.mnu-bw = {
    Unit = {
      Description = "mnu-bw menu server";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.mnu-bw}/bin/mnu-bw serve";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
