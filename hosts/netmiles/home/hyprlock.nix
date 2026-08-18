{ config, ... }:
let
  colors = config.lib.stylix.colors;
in
{
  # Lock screen. Stylix (targets.hyprlock) supplies the wallpaper background
  # and input-field colors; PAM comes from the hyprland mixin
  # (security.pam.services.hyprlock). River keeps its swaylock bind.
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background.blur_passes = 2;

      input-field = {
        size = "300, 50";
        position = "0, -80";
        halign = "center";
        valign = "center";
        rounding = 12;
        dots_center = true;
        fade_on_empty = true;
      };

      label = [
        {
          text = ''cmd[update:1000] date +"%H:%M"'';
          font_size = 96;
          font_family = config.stylix.fonts.monospace.name;
          color = "rgb(${colors.base05})";
          position = "0, 120";
          halign = "center";
          valign = "center";
        }
        {
          text = ''cmd[update:60000] date +"%A %d %B"'';
          font_size = 20;
          font_family = config.stylix.fonts.monospace.name;
          color = "rgb(${colors.base04})";
          position = "0, 40";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  # Idle management, scoped to the hyprland session so river is unaffected.
  # hyprctl dispatch takes lua expressions now (legacy "dpms off" syntax is
  # rejected under a lua config).
  services.hypridle = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = {
      general = {
        # Retry loop: hyprlock exits 0 only on real unlock; if it crashes
        # (e.g. on dpms output churn) relaunch into the still-locked session
        # (needs misc.allow_session_lock_restore in hyprland)
        lock_cmd = "pidof hyprlock || until hyprlock; do sleep 0.5; done";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
      };

      listener = [
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch 'hl.dsp.dpms({ action = \"disable\" })'";
          on-resume = "hyprctl dispatch 'hl.dsp.dpms({ action = \"enable\" })'";
        }
      ];
    };
  };
}
