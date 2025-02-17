{ pkgs, lib, config, ... }:

{

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    systemd.enable = true;
    config = {
      bars = [];
      input = {
        "*" = {
          xkb_layout = "no";
        };
      };
      keybindings =
        let
          mod = config.wayland.windowManager.sway.config.modifier;
          grim = "${pkgs.grim}/bin/grim";
          slurp = "${pkgs.slurp}/bin/slurp";
        in
        lib.mkOptionDefault {
          "${mod}+bar" = "splith";
          "${mod}+minus" = "splitv";
          "${mod}+Shift+b" = "move scratchpad";
          "${mod}+b" = "scratchpad show";
          "--release Print" = ''exec ${grim} -g \"$(${slurp})" - | wl-copy'';
          "${mod}+l" = "exec swaylock --color 3c3836";
        };
        terminal = "foot";
      #menu = "wofi --show run | xargs waymsg exec --";
      menu = "tofi-drun --drun-launch=true";
      focus = {
        followMouse = false;
      };
      modifier = "Mod4";
      floating = {
        criteria = [
          { window_role = "pop-up"; }
          { window_role = "bubble"; }
          { window_role = "dialog"; }
          { window_type = "dialog"; }
          { app_id = "pavucontrol"; }
        ];
      };
      window = {
        titlebar = false;
        hideEdgeBorders = "smart";
        commands = [
          {
            command = "focus";
            criteria = {
              urgent = "latest";
            };
          }
          {
            command = "floating enable, resize set width 1030 height 710";
            criteria = {
              title = "(?:Open|Save) (?:File|Folder|As)";
            };
          }
          # { command = "floating enable"; criteria = { app_id = "gsimplecal"; }; }
          #{ command = "floating enable"; criteria = { app_id = "firefox-nightly"; title = "About Firefox Nightly"; }; }
          { command = "move container to workspace 9"; criteria = { class = "Slack"; }; }
          #{ command = "move container to workspace 9"; criteria = { title = "Chat | Microsoft Teams classic"; }; }
          #{ command = "move container to workspace 9"; criteria = { class = "Microsoft Teams - Preview"; }; }
          #{ command = "move container to workspace 3"; criteria = { class = "Google-chrome"; }; }
          #{ command = "floating enable, resize set width 600px height 800px"; criteria = { title = "Save File"; }; }
          # browser zoom|meet|bluejeans
          #{ command = "inhibit_idle visible"; criteria = { title = "(Blue Jeans)|(Meet)|(Zoom Meeting)"; }; }
          #{ command = "inhibit_idle visible, floating enable"; criteria = { title = "(Sharing Indicator)"; }; }
        ];
      };
     gaps = {
        inner = 5;
        outer = 5;
      };
      startup = [
        { command = "mako"; }
        { command = "systemctl --user restart waybar"; always = true; }
#        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY DBUS_SESSION_BUS_ADDRESS SWAYSOCK XDG_SESSION_TYPE XDG_SESSION_DESKTOP XDG_CURRENT_DESKTOP NIXOS_OZONE_WL"; } #workaround
#{
#  command = ''swayidle -w \
#  timeout 300 'swaylock --daemonize --color 3c3836' \
#  timeout 600 'swaymsg "output * dpms off"' \
#  resume 'swaymsg "output * dpms on"' \
#  before-sleep 'swaylock --daemonize --color 3c3836'
#  '';
#}
#{ command = "google-chrome-stable --app='https://teams.microsoft.com'"; }
{ command = "foot"; }
#        { command = "google-chrome-stable"; }
{ command = "slack --logLevel=error"; }
#        { command = "teams"; }
{ command = "nm-applet --indicator"; always = true; }
{ command = "blueman-applet"; always = true; }
      ];
#      output = {
#        # swaymsg -t get_outputs
#        Virtual-1 = {
#          mode = "2560x1600@59.987Hz";
#        };
#      };

    };
  };
}
