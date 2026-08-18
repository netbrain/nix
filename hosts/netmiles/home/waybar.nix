{ config, pkgs, lib, ... }:

let
  # Script to read memory pressure from PSI
  memPressureScript = pkgs.writeShellScript "memory-pressure" ''
    #!/bin/sh
    PATH=${pkgs.gawk}/bin:${pkgs.bc}/bin:${pkgs.coreutils}/bin

    # Read PSI memory pressure (avg60 = 60 second average)
    if [ -f /proc/pressure/memory ]; then
      # Extract the avg60 value from the "some" line
      pressure=$(awk '/^some/ {gsub(/avg60=/, "", $3); print $3}' /proc/pressure/memory)

      # Round to 1 decimal place
      pressure=$(printf "%.1f" "$pressure")

      # Color based on pressure level
      if (( $(echo "$pressure >= 40" | ${pkgs.bc}/bin/bc -l) )); then
        class="critical"
        icon="󰀪"  # High pressure
      elif (( $(echo "$pressure >= 20" | ${pkgs.bc}/bin/bc -l) )); then
        class="warning"
        icon="󰀦"  # Medium pressure
      else
        class="normal"
        icon="󰀦"  # Low pressure
      fi

      # Output in waybar custom module format
      echo "{\"text\": \"$icon $pressure%\", \"class\": \"$class\", \"percentage\": $pressure}"
    else
      echo "{\"text\": \"N/A\", \"class\": \"disabled\"}"
    fi
  '';
in
{
  # Stylix still injects the base16 palette (@base00..@base0F) and fonts;
  # addCss = false drops its generic bar CSS so the pill style below owns
  # the look in both river and hyprland sessions.
  stylix.targets.waybar.addCss = false;

  programs.waybar = {
    enable = true;
    # Hyprland 0.55+ IPC evaluates dispatch as lua, so waybar's hardcoded
    # workspace-click commands ("dispatch workspace N") fail with a parse
    # error. Rewrite them to hl.dsp.* until waybar catches up. Not patched:
    # the move-to-monitor branches (focusworkspaceoncurrentmonitor) — that
    # option stays unusable.
    package = pkgs.waybar.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/modules/hyprland/workspace.cpp \
          --replace-fail '"dispatch workspace " + std::to_string(id())' \
                         '"dispatch hl.dsp.focus({ workspace = " + std::to_string(id()) + " })"' \
          --replace-fail '"dispatch workspace name:" + name()' \
                         '"dispatch hl.dsp.focus({ workspace = \"name:" + name() + "\" })"' \
          --replace-fail '"dispatch togglespecialworkspace " + name()' \
                         '"dispatch hl.dsp.workspace.toggle_special(\"" + name() + "\")"' \
          --replace-fail '"dispatch togglespecialworkspace"' \
                         '"dispatch hl.dsp.workspace.toggle_special()"'
      '';
    });
    systemd = {
      enable = true;
      # Started by whichever compositor session binds graphical-session.target
      targets = [ "graphical-session.target" ];
    };
    settings = [{
      height = 34;
      layer = "top";
      position = "bottom";
      tray = { spacing = 10; };
      #modules-center = [ "sway/window" "river/window" ];
      #modules-left = [ "sway/workspaces" "sway/mode" "wlr/workspaces" ];
      # Waybar drops the modules of whichever compositor isn't running
      modules-center = [ "river/window" "hyprland/window" ];
      modules-left = [ "river/tags" "hyprland/workspaces" ];
      modules-right = [
        "custom/memory-pressure"
        "cpu"
        "disk"
        "memory"
        "battery"
        "network"
        "temperature"
        "pulseaudio"
        "tray"
        "clock"
      ];

      battery = {
        format = "{icon} {capacity}%";
        format-alt = "{icon} {time}";
        format-charging = "  {capacity}%";
        format-icons = [ "" "" "" "" "" ];
        format-plugged = " {capacity}%";
        states = {
          critical = 15;
          warning = 30;
        };
      };

      "river/tags" = {
        num-tags = 6;
        tag-labels = [ "1www" "2dev" "3comms" "4mail" "5" "6" ];
      };

      # No tag-labels here (river-only); labels come from format-icons,
      # keyed by workspace name. persistent-workspaces keeps all six
      # visible like river's tags.
      "hyprland/workspaces" = {
        format = "{icon}";
        format-icons = {
          "1" = "1www";
          "2" = "2dev";
          "3" = "3comms";
          "4" = "4mail";
          "5" = "5";
          "6" = "6";
          # Name-keyed so the special pill doesn't fall back to state icons
          "scratch" = "scratch";
        };
        persistent-workspaces = { "*" = [ 1 2 3 4 5 6 ]; };
        # Show the scratch special workspace as a pill, but only while open
        show-special = true;
        special-visible-only = true;
        on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e-1\" })'";
        on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({ workspace = \"e+1\" })'";
      };

      # Icon is off by default; resolved from the window class via the
      # gtk icon theme
      "hyprland/window" = {
        icon = true;
        icon-size = 20;
        # Each bar shows its own monitor's focused window
        separate-outputs = true;
      };

      "custom/memory-pressure" = {
        exec = "${memPressureScript}";
        return-type = "json";
        interval = 5;
        tooltip = true;
        tooltip-format = "Memory Pressure (60s avg): {}%";
      };

      cpu = {
        format = " {icon} {usage}%";
        tooltip = true;
        states = {
          warning = 70;
          critical = 90;
        };
      };

      disk = {
        format = " {percentage_used}%";
        path = "/";
        tooltip-format = "Used: {used} / {total}";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      memory = {
        format = " {percentage}%";
        tooltip-format = "RAM: {used}GiB / {total}GiB";
        states = {
          warning = 70;
          critical = 90;
        };
      };

      network = {
        format-wifi = "  {essid}";
        format-ethernet = "  {ipaddr}";
        format-disconnected = "󰤭 Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
        tooltip-format-wifi = "{essid} ({signalStrength}%)\n {bandwidthDownBits}  {bandwidthUpBits}";
      };

      temperature = {
        critical-threshold = 80;
        format = "{icon} {temperatureC}°C";
        format-icons = [ "" "" "" "" "" ];
        tooltip = true;
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = " {volume}%";
        format-icons = {
          default = [ "" "" "" ];
        };
        on-click = "pavucontrol";
      };

      clock = {
        format = " {:%H:%M}";
        format-alt = " {:%Y-%m-%d}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
        calendar = {
          mode = "year";
          mode-mon-col = 3;
          weeks-pos = "right";
          on-scroll = 1;
          format = {
            months = "<span color='#fabd2f'><b>{}</b></span>";
            days = "<span color='#ebdbb2'><b>{}</b></span>";
            weeks = "<span color='#8ec07c'><b>W{}</b></span>";
            weekdays = "<span color='#fabd2f'><b>{}</b></span>";
            today = "<span color='#fe8019'><b><u>{}</u></b></span>";
          };
        };
      };
    }];

    style = ''
      /* Colors come from stylix as @base00..@base0F; accents map to the
         gruvbox roles: base09 orange, base08 red, base0A yellow, base0B
         green. Transparent bar with pill-shaped module groups. */
      window#waybar {
        background: transparent;
      }
      window#waybar * {
        font-size: 13pt;
        font-family: "NotoSansM Nerd Font", monospace;
      }

      .modules-left,
      .modules-center,
      .modules-right {
        background: alpha(@base00, 0.85);
        border: 1px solid alpha(@base03, 0.6);
        border-radius: 14px;
        margin: 3px 6px;
        padding: 0 8px;
      }

      /* river tags + hyprland workspaces share the pill look */
      #tags button,
      #workspaces button {
        color: @base04;
        background: transparent;
        border: none;
        border-radius: 10px;
        padding: 0 8px;
        margin: 3px 2px;
      }
      #tags button.occupied,
      #workspaces button:not(.empty) {
        color: @base05;
      }
      #tags button.focused,
      #workspaces button.active {
        background: alpha(@base09, 0.2);
        color: @base09;
      }
      #workspaces button.special {
        color: @base0A;
      }
      #tags button.urgent,
      #workspaces button.urgent {
        background: alpha(@base08, 0.25);
        color: @base08;
      }

      #window {
        color: @base05;
        padding: 0 12px;
      }

      #custom-memory-pressure,
      #cpu,
      #disk,
      #memory,
      #battery,
      #network,
      #temperature,
      #pulseaudio,
      #tray,
      #clock {
        color: @base05;
        padding: 0 10px;
      }

      #clock {
        color: @base09;
        font-weight: bold;
      }

      #battery.charging {
        color: @base0B;
      }
      #battery.warning:not(.charging) {
        color: @base0A;
      }
      #battery.critical:not(.charging) {
        color: @base08;
        font-weight: bold;
      }

      #network.disconnected {
        color: @base08;
      }
      #pulseaudio.muted {
        color: @base04;
      }

      #custom-memory-pressure.normal {
        color: @base0B;
      }
      #custom-memory-pressure.warning,
      #cpu.warning,
      #disk.warning,
      #memory.warning {
        color: @base0A;
      }
      #custom-memory-pressure.critical,
      #cpu.critical,
      #disk.critical,
      #memory.critical,
      #temperature.critical {
        color: @base08;
        font-weight: bold;
      }

      tooltip {
        background: @base00;
        border: 1px solid @base03;
        border-radius: 10px;
      }
      tooltip * {
        font-size: 12pt;
      }
    '';
  };
}
