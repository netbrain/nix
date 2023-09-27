{ ... }:

{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "sway-session.target";
    };
    settings = [{
      height = 30;
      layer = "top";
      position = "bottom";
      tray = { spacing = 10; };
      modules-center = [ "sway/window" ];
      modules-left = [ "sway/workspaces" "sway/mode" ];
      modules-right = [
        "battery"
        "cpu"
        "disk"
        "memory"
        "network"
        "temperature"
        "pulseaudio"
        "tray"
        "clock"
      ];

      battery = {
        format = "{capacity}% {icon}";
        format-alt = "{time} {icon}";
        format-charging = "{capacity}% ";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = "{capacity}% ";
        states = {
          critical = 15;
          warning = 30;
        };
      };
    }];
  };
}
