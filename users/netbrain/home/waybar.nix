{ config, pkgs, lib, ... }:

let
  riverTagsEnabled = builtins.getEnv "HOSTNAME" != "netbox";
in
{
  programs.waybar = {
    enable = true;
    systemd = {
      enable = true;
      target = "river-session.target";
    };
    settings = [{
      height = 30;
      layer = "top";
      position = "bottom";
      tray = { spacing = 10; };
      #modules-center = [ "sway/window" "river/window" ];
      #modules-left = [ "sway/workspaces" "sway/mode" "wlr/workspaces" ];
      modules-center = [ "river/window" ];
      modules-left = [ "river/tags" ];
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

      "river/tags" = lib.mkIf riverTagsEnabled {
        num-tags = 6;
        tag-labels = [ "1www" "2dev" "3comms" "4mail" "5" "6" ];
      };    
    }];

    style = ''
      #tags button.focused {
        color: #d65d0e;
      }
      #tags button.urgent {
        color: #fb4934;
      }
    '';
  };
}
