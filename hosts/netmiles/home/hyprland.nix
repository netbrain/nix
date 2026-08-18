{ pkgs, lib, ... }:
let
  inherit (lib.generators) mkLuaInline;
  # hl.bind(combo, dispatcher) / hl.bind(combo, dispatcher, opts)
  bind = combo: dsp: { _args = [ combo (mkLuaInline dsp) ]; };
  bindWith = combo: dsp: opts: { _args = [ combo (mkLuaInline dsp) opts ]; };
in
{
  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprland 0.55+ deprecated hyprlang .conf configs; this renders
    # ~/.config/hypr/hyprland.lua instead. NOTE: hyprctl dispatch now takes
    # lua syntax, e.g. hyprctl dispatch 'hl.dsp.exec_cmd("foot")'.
    configType = "lua";
    # systemd integration (default on) starts hyprland-session.target, which
    # binds graphical-session.target -> waybar/kanshi/mako/applets come up
    # exactly like under river.

    # Renders these settings first, in this order: env before anything reads
    # it, config before rules, and curves before hl.animation() calls that
    # reference them (the rest is rendered alphabetically, animation < curve).
    importantPrefixes = [ "env" "config" "curve" ];

    settings = {
      env = [
        { _args = [ "MOZ_ENABLE_WAYLAND" "1" ]; }
        { _args = [ "NIXOS_OZONE_WL" "1" ]; }
      ];

      # Everything under here becomes one hl.config({ ... }) call, merged
      # with stylix's colors (targets.hyprland writes settings.config too:
      # borders, shadow color, groupbar, background_color).
      config = {
        input = {
          kb_layout = "no";
          repeat_rate = 50;
          repeat_delay = 300;
          follow_mouse = 1;
          touchpad.natural_scroll = true;
        };

        cursor.hide_on_key_press = true;

        general = {
          # dwindle is the closest match to river's bsp-layout
          layout = "dwindle";
          gaps_in = 4;
          gaps_out = 8;
          border_size = 2;
          # border colors come from stylix (targets.hyprland via autoEnable)
        };

        dwindle.preserve_split = true;

        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            # foot's stylix alpha (0.8) only blurs with ignore_opacity on
            ignore_opacity = true;
            popups = true;
            vibrancy = 0.17;
          };
          shadow = {
            enabled = true;
            range = 12;
            render_power = 3;
            # color comes from stylix
          };
          dim_inactive = true;
          dim_strength = 0.12;
        };

        animations.enabled = true;

        misc = {
          # hyprlock 0.9.6 can abort on the output churn a DP monitor causes
          # when dpms powers it off (seen 2026-08-18, hyprlock.cpp:414
          # assert); let a fresh locker re-attach to the locked session
          allow_session_lock_restore = true;

          disable_hyprland_logo = true;
          disable_splash_rendering = true;
          force_default_wallpaper = 0;
          # background_color comes from stylix, like the border colors

          # GUI apps launched from a foot terminal take over its window
          enable_swallow = true;
          swallow_regex = "^foot$";
        };
      };

      # Upstream default curve/animation set (share/hypr/hyprland.lua); the
      # lua config ships no curves of its own, so these must be declared.
      curve = [
        { _args = [ "easeOutQuint" { type = "bezier"; points = [ [ 0.23 1 ] [ 0.32 1 ] ]; } ]; }
        { _args = [ "easeInOutCubic" { type = "bezier"; points = [ [ 0.65 0.05 ] [ 0.36 1 ] ]; } ]; }
        { _args = [ "linear" { type = "bezier"; points = [ [ 0 0 ] [ 1 1 ] ]; } ]; }
        { _args = [ "almostLinear" { type = "bezier"; points = [ [ 0.5 0.5 ] [ 0.75 1 ] ]; } ]; }
        { _args = [ "quick" { type = "bezier"; points = [ [ 0.15 0 ] [ 0.1 1 ] ]; } ]; }
        { _args = [ "easy" { type = "spring"; mass = 1; stiffness = 238.1191; dampening = 24.21279333; } ]; }
      ];

      animation = [
        { leaf = "global"; enabled = true; speed = 10; bezier = "default"; }
        { leaf = "border"; enabled = true; speed = 5.39; bezier = "easeOutQuint"; }
        { leaf = "windows"; enabled = true; speed = 4.79; spring = "easy"; }
        { leaf = "windowsIn"; enabled = true; speed = 4.1; spring = "easy"; style = "popin 87%"; }
        { leaf = "windowsOut"; enabled = true; speed = 1.49; bezier = "linear"; style = "popin 87%"; }
        { leaf = "fadeIn"; enabled = true; speed = 1.73; bezier = "almostLinear"; }
        { leaf = "fadeOut"; enabled = true; speed = 1.46; bezier = "almostLinear"; }
        { leaf = "fade"; enabled = true; speed = 3.03; bezier = "quick"; }
        { leaf = "layers"; enabled = true; speed = 3.81; bezier = "easeOutQuint"; }
        { leaf = "layersIn"; enabled = true; speed = 4; bezier = "easeOutQuint"; style = "fade"; }
        { leaf = "layersOut"; enabled = true; speed = 1.5; bezier = "linear"; style = "fade"; }
        { leaf = "fadeLayersIn"; enabled = true; speed = 1.79; bezier = "almostLinear"; }
        { leaf = "fadeLayersOut"; enabled = true; speed = 1.39; bezier = "almostLinear"; }
        { leaf = "workspaces"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
        { leaf = "workspacesIn"; enabled = true; speed = 1.21; bezier = "almostLinear"; style = "fade"; }
        { leaf = "workspacesOut"; enabled = true; speed = 1.94; bezier = "almostLinear"; style = "fade"; }
        { leaf = "zoomFactor"; enabled = true; speed = 7; bezier = "quick"; }
      ];

      bind = [
        # Launchers (same floating foot pattern as river)
        (bind "SUPER + D" ''hl.dsp.exec_cmd("foot -a mnu-drun -t Launcher -e mnu-drun")'')
        (bind "SUPER + P" ''hl.dsp.exec_cmd("foot -a mnu-bw -t Passwords -e mnu-bw")'')
        (bind "SUPER + SHIFT + Return" ''hl.dsp.exec_cmd("foot")'')

        (bind "SUPER + SHIFT + Q" "hl.dsp.window.close()")
        (bind "SUPER + SHIFT + E" "hl.dsp.exit()")

        # Focus / swap in stack (river: Super+J/K, Super+Shift+J/K)
        (bind "SUPER + J" "hl.dsp.window.cycle_next()")
        (bind "SUPER + K" "hl.dsp.window.cycle_next({ next = false })")
        (bind "SUPER + SHIFT + J" "hl.dsp.window.swap({ next = true })")
        (bind "SUPER + SHIFT + K" "hl.dsp.window.swap({ prev = true })")

        # Split ratio (river: Super+H/L on bsp-layout)
        (bind "SUPER + H" ''hl.dsp.layout("splitratio -0.05")'')
        (bind "SUPER + L" ''hl.dsp.layout("splitratio +0.05")'')

        # Outputs (river: Super+Period/Comma)
        (bind "SUPER + Period" ''hl.dsp.focus({ monitor = "+1" })'')
        (bind "SUPER + Comma" ''hl.dsp.focus({ monitor = "-1" })'')
        (bind "SUPER + SHIFT + Period" ''hl.dsp.window.move({ monitor = "+1" })'')
        (bind "SUPER + SHIFT + Comma" ''hl.dsp.window.move({ monitor = "-1" })'')

        # Move/resize floating views (river: Super+Alt / Super+Alt+Shift)
        (bind "SUPER + ALT + H" "hl.dsp.window.move({ x = -100, y = 0, relative = true })")
        (bind "SUPER + ALT + J" "hl.dsp.window.move({ x = 0, y = 100, relative = true })")
        (bind "SUPER + ALT + K" "hl.dsp.window.move({ x = 0, y = -100, relative = true })")
        (bind "SUPER + ALT + L" "hl.dsp.window.move({ x = 100, y = 0, relative = true })")
        (bind "SUPER + ALT + SHIFT + H" "hl.dsp.window.resize({ x = -100, y = 0, relative = true })")
        (bind "SUPER + ALT + SHIFT + J" "hl.dsp.window.resize({ x = 0, y = 100, relative = true })")
        (bind "SUPER + ALT + SHIFT + K" "hl.dsp.window.resize({ x = 0, y = -100, relative = true })")
        (bind "SUPER + ALT + SHIFT + L" "hl.dsp.window.resize({ x = 100, y = 0, relative = true })")

        (bind "SUPER + Space" "hl.dsp.window.float()")
        (bind "SUPER + F" "hl.dsp.window.fullscreen()")
        (bind "SUPER + mouse:274" "hl.dsp.window.float()")

        # Scratchpad (river's tag 20 trick -> special workspace)
        (bind "SUPER + O" ''hl.dsp.workspace.toggle_special("scratch")'')
        (bind "SUPER + SHIFT + O" ''hl.dsp.window.move({ workspace = "special:scratch", follow = false })'')

        # Screenshots: Print annotates in satty, Shift+Print copies raw
        (bind "Print" ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | satty --filename - --output-filename \"$HOME/Pictures/screenshots/%Y-%m-%d_%H-%M-%S.png\" --early-exit")'')
        (bind "SHIFT + Print" ''hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy")'')

        # Colorpicker / clipboard history / lock
        (bind "SUPER + C" ''hl.dsp.exec_cmd("hyprpicker -n -r | wl-copy")'')
        (bind "SUPER + V" ''hl.dsp.exec_cmd("cliphist list | tofi --prompt-text clip: | cliphist decode | wl-copy")'')
        (bind "SUPER + X" ''hl.dsp.exec_cmd("hyprlock")'')
      ]
      # Workspaces 1-6 (river tags; Shift moves without following)
      ++ lib.concatLists (lib.genList (i:
        let ws = toString (i + 1);
        in [
          (bind "SUPER + ${ws}" "hl.dsp.focus({ workspace = ${ws} })")
          (bind "SUPER + SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${ws}, follow = false })")
        ]) 6)
      ++ [
        # Media keys work when locked (river's "locked" mode maps);
        # volume/brightness also repeat while held
        (bindWith "XF86AudioMute" ''hl.dsp.exec_cmd("pamixer --toggle-mute")'' { locked = true; })
        (bindWith "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'' { locked = true; })
        (bindWith "XF86AudioMedia" ''hl.dsp.exec_cmd("playerctl play-pause")'' { locked = true; })
        (bindWith "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'' { locked = true; })
        (bindWith "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'' { locked = true; })
        (bindWith "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("pamixer -i 5")'' { locked = true; repeating = true; })
        (bindWith "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("pamixer -d 5")'' { locked = true; repeating = true; })
        (bindWith "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("brightnessctl set +5%")'' { locked = true; repeating = true; })
        (bindWith "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("brightnessctl set 5%-")'' { locked = true; repeating = true; })

        # Mouse drag/resize (river: Super+LMB/RMB)
        (bindWith "SUPER + mouse:272" "hl.dsp.window.drag()" { mouse = true; })
        (bindWith "SUPER + mouse:273" "hl.dsp.window.resize()" { mouse = true; })

        # Passthrough mode for nested compositors (river's Super+F11)
        (bind "SUPER + F11" ''hl.dsp.submap("passthrough")'')
      ];

      # Touchpad gestures
      gesture = [
        { fingers = 3; direction = "horizontal"; action = "workspace"; }
        { fingers = 4; direction = "down"; action = "special"; workspace_name = "scratch"; }
        { fingers = 4; direction = "up"; action = "fullscreen"; }
      ];

      window_rule = [
        # mnu launchers: floating centered panel, visible everywhere
        # (river rule-add + all_tags)
        {
          name = "launcher-mnu-drun";
          match.class = "^(mnu-drun)$";
          float = true;
          pin = true;
          center = true;
          size = [ "(monitor_w*0.35)" "(monitor_h*0.45)" ];
          animation = "popin";
        }
        {
          name = "launcher-mnu-bw";
          match.class = "^(mnu-bw)$";
          float = true;
          pin = true;
          center = true;
          size = [ "(monitor_w*0.35)" "(monitor_h*0.45)" ];
          animation = "popin";
        }

        # Chromium extension popups (metamask, bitwarden)
        { match.title = "^(_crx_nkbihfbeogaeaoehlefnkodbefgpgknn)$"; float = true; }
        { match.title = "^(_crx_nngceckbapebfimnlniiiahkandclblb)$"; float = true; }

        # Settings-style dialogs: float + center + half size
        {
          match.class = "^(.blueman-manager-wrapped)$";
          float = true;
          center = true;
          size = [ "(monitor_w*0.5)" "(monitor_h*0.5)" ];
        }
        {
          match.class = "^(nm-connection-editor)$";
          float = true;
          center = true;
          size = [ "(monitor_w*0.5)" "(monitor_h*0.5)" ];
        }
        {
          match.class = "^(pavucontrol)$";
          float = true;
          center = true;
          size = [ "(monitor_w*0.5)" "(monitor_h*0.5)" ];
        }

        # Upstream-recommended defaults: ignore app maximize requests, and
        # don't focus empty xwayland drag surfaces
        { name = "suppress-maximize"; match.class = ".*"; suppress_event = "maximize"; }
        {
          name = "xwayland-drag-fix";
          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };
          no_focus = true;
        }
      ];
    };

    submaps.passthrough.settings.bind = [
      { _args = [ "SUPER + F11" (mkLuaInline ''hl.dsp.submap("reset")'') ]; }
    ];
  };

  # Wallpaper under hyprland; stylix (targets.hyprpaper) supplies the config
  # from stylix.image. River keeps its flat background-color.
  services.hyprpaper.enable = true;

  # Screenshot annotation + clipboard history (watchers live in session.nix)
  home.packages = with pkgs; [ satty cliphist ];
  systemd.user.tmpfiles.rules = [ "d %h/Pictures/screenshots - - - -" ];

  # dmenu-style picker for the cliphist bind; stylix themes it via autoEnable
  programs.tofi.enable = true;
}
