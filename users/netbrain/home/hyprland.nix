{
  wayland.windowManager.hyprland = {
    enable = true;
    extraConfig = ''
      # Load wallpapers
      #exec-once = hyprpaper

      # Monitor settings
      #monitor = DP-1, preferred, auto, 1
      #monitor = eDP-1, preferred, auto, 2

      # Execute your favorite apps at launch
      #exec-once = hypridle
      #exec-once = gnome-keyring-daemon --start --components=secrets
      exec-once = kanshi
      exec-once = nm-applet —-indicator
      #exec-once = swaync
      #exec-once = ulauncher --hide-window
      exec-once = waybar
      #exec-once = wl-paste --watch cliphist store
      #exec-once = wlsunset -l 52.23 -L 21.01

      # Input device setting
      input {
          kb_layout = no
          kb_options = grp:win_space_toggle
          repeat_delay = 250
          repeat_rate = 40

          follow_mouse = 1
          mouse_refocus = false

          touchpad {
              natural_scroll = yes
          }

          sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
          accel_profile = flat
      }

      # General settings
      general {
          allow_tearing = false
          border_size = 1
          col.active_border = rgb(b7bdf8)
          gaps_in = 5
          gaps_out = 20
          layout = master
      }

      # Window decorations settings
      decoration {
          rounding = 0
          blur {
              enabled = false
              size = 3
              passes = 1
          }
          drop_shadow = false
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      # Animations settings
      animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      # Layouts settings
      dwindle {
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }

      master {
          orientation = left
          mfact = 0.50
      }

      # Mouse gestures settings
      gestures {
          workspace_swipe = on
      }

      # Misc settings
      misc {
          force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
          disable_hyprland_logo = true
          disable_splash_rendering = true
      }

      # Window rules
      # Center specific windows
      windowrule = center 1, ^(.blueman-manager-wrapped)$
      #windowrule = center 1, ^(gnome-calculator|org\.gnome\.Calculator)$
      windowrule = center 1, ^(nm-connection-editor)$
      windowrule = center 1, ^(pavucontrol)$

      # Float specific windows
      windowrule = float, ^(.blueman-manager-wrapped)$
      #windowrule = float, ^(gnome-calculator|org\.gnome\.Calculator)$
      windowrule = float, ^(nm-connection-editor)$
      windowrule = float, ^(pavucontrol)$
      #windowrule = float, ^(ulauncher)$
      #windowrule = float, zoom

      # Remove border for specific applications
      #windowrule = noborder, ^(ulauncher)$

      # Set size for specific windows
      windowrule = size 50%, ^(.blueman-manager-wrapped)$
      windowrule = size 50%, ^(nm-connection-editor)$
      windowrule = size 50%, ^(pavucontrol)$

      # Keep focus on specific windows when they open
      windowrule = stayfocused, ^(.blueman-manager-wrapped)$
      #windowrule = stayfocused, ^(gnome-calculator|org\.gnome\.Calculator)$
      windowrule = stayfocused, ^(nm-connection-editor)$
      windowrule = stayfocused, ^(pavucontrol)$
      #windowrule = stayfocused, ^(swappy)$
      #windowrule = stayfocused, ^(ulauncher)$

      # Assign applications to specific workspaces
      windowrule = workspace 1, title:Brave
      windowrule = workspace 2, title:Alacritty
      windowrule = workspace 3, title:Telegram
      windowrule = workspace 4, title:OBS
      windowrule = workspace 4, title:Spotify
      windowrule = workspace 4, title:Steam
      windowrule = workspace 5 silent, zoom
      windowrule = workspace special, title:Pomodoro

      # Bindings
      $mainMod = SUPER

      bind = $mainMod SHIFT, Return, exec, foot
      #bind = $mainMod SHIFT, B, exec, brave
      #bind = $mainMod SHIFT, F, exec, nautilus
      #bind = $mainMod SHIFT, T, exec, telegram-desktop
      #bind = CTRL ALT, P, exec, gnome-pomodoro --start-stop
      bind = $mainMod, Return, layoutmsg, swapwithmaster
      bind = $mainMod, Q, killactive,
      bind = CTRL SHIFT, E, exit
      bind = $mainMod, F, togglefloating
      bind = $mainMod, M, fullscreen
      bind = $mainMod SHIFT, M, movetoworkspacesilent, special
      bind = $mainMod SHIFT, P, togglespecialworkspace
      bind = $mainMod SHIFT, C, exec, hyprpicker -a

      # Move focus with mainMod + arrow keys
      bind = $mainMod, l, movefocus, l
      bind = $mainMod, h, movefocus, r
      bind = $mainMod, k, movefocus, u
      bind = $mainMod, j, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10

      # Switch to next/previous workspace
      bind = CTRL ALT, left, workspace, m-1
      bind = CTRL ALT, right, workspace, m+1

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10

      # Scroll through existing workspaces with mainMod + scroll
      bind = $mainMod, mouse_down, workspace, e+1
      bind = $mainMod, mouse_up, workspace, e-1

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = $mainMod, mouse:272, movewindow
      bindm = $mainMod, mouse:273, resizewindow

      # Application menu
      bind = $mainMod, D, exec, tofi-drun

      # Center focused window
      bind = CTRL ALT, C, centerwindow

      # Clipboard
      #bind = ALT SHIFT, V, exec, cliphist list | wofi --show dmenu | cliphist decode | wl-copy

      # Ulauncher
      #bind = CTRL, Space, exec, ulauncher-toggle

      # Screenshot area
      #bind = $mainMod SHIFT, S, exec, grim -g "$(slurp)" - | swappy -f -

      # Screenshot entire screen
      #bind = $mainMod CTRL, S, exec, grim - | swappy -f -

      # Screen recording
      #bind = $mainMod SHIFT, R, exec, $HOME/.local/bin/screen-recorder

      # OCR
      #bind = ALT SHIFT, 2, exec, grim -t png -g "$(slurp)" - | tesseract stdin stdout -l "eng+rus+pol" | tr -d '\f' | wl-copy

      # Lock screen
      #bind = $mainMod SHIFT, L, exec, hyprlock

      # Adjust brightness
      #bind = , XF86MonBrightnessUp, exec, brightnessctl set +10%
      #bind = , XF86MonBrightnessDown, exec, brightnessctl set 10%-

      # Open notifications
      #bind = $mainMod, V, exec, swaync-client -t -sw

      # Adjust  volume
      #bind = , XF86AudioRaiseVolume, exec, pamixer --increase 10
      #bind = , XF86AudioLowerVolume, exec, pamixer --decrease 10
      #bind = , XF86AudioMute, exec, pamixer --toggle-mute
      #bind = , XF86AudioMicMute, exec, pamixer --default-source --toggle-mute

      # Adjust mic sensitivity
      #bind = SHIFT, XF86AudioRaiseVolume, exec, pamixer --increase 10 --default-source
      #bind = SHIFT, XF86AudioLowerVolume, exec, pamixer --decrease 10 --default-source

      # Adjust keyboard backlight
      #bind = SHIFT, XF86MonBrightnessUp, exec, brightnessctl -d tpacpi::kbd_backlight set +33%
      #bind = SHIFT, XF86MonBrightnessDown, exec, brightnessctl -d tpacpi::kbd_backlight set 33%-
    '';
  };
}
