{
  wayland.windowManager.river = {
    enable = true;
    extraSessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP="river";
    };
    extraConfig = ''
      # Super+D start instance of wofi
      riverctl map normal Super D spawn "exec \$(tofi-drun)"
    
      # Super+Shift+Return to start an instance of foot (https://codeberg.org/dnkl/foot)
      riverctl map normal Super+Shift Return spawn foot

      # Super+(Shift)+Q to close the focused view
      riverctl map normal Super+Shift Q close
      # riverctl map normal Super Q close

      # Super+Shift+E to exit river
      riverctl map normal Super+Shift E exit

      # Super+J and Super+K to focus the next/previous view in the layout stack
      riverctl map normal Super J focus-view next
      riverctl map normal Super K focus-view previous

      # Super+Shift+J and Super+Shift+K to swap the focused view with the next/previous
      # view in the layout stack
      riverctl map normal Super+Shift J swap next
      riverctl map normal Super+Shift K swap previous

      # Super+Period and Super+Comma to focus the next/previous output
      riverctl map normal Super Period focus-output next
      riverctl map normal Super Comma focus-output previous

      # Super+Shift+{Period,Comma} to send the focused view to the next/previous output
      riverctl map normal Super+Shift Period send-to-output next
      riverctl map normal Super+Shift Comma send-to-output previous

      # Super+Return to bump the focused view to the top of the layout stack
      riverctl map normal Super Return zoom

      # Super+H and Super+L to decrease/increase the main ratio of rivertile(1)riverctl map normal Super+D spawn tofi-drun
      riverctl map normal Super H send-layout-cmd rivertile "main-ratio -0.05"
      riverctl map normal Super L send-layout-cmd rivertile "main-ratio +0.05"

      # Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
      riverctl map normal Super+Shift H send-layout-cmd rivertile "main-count +1"
      riverctl map normal Super+Shift L send-layout-cmd rivertile "main-count -1"

      # Super+Alt+{H,J,K,L} to move views
      riverctl map normal Super+Alt H move left 100
      riverctl map normal Super+Alt J move down 100
      riverctl map normal Super+Alt K move up 100
      riverctl map normal Super+Alt L move right 100

      # Super+Alt+Control+{H,J,K,L} to snap views to screen edges
      riverctl map normal Super+Alt+Control H snap left
      riverctl map normal Super+Alt+Control J snap down
      riverctl map normal Super+Alt+Control K snap up
      riverctl map normal Super+Alt+Control L snap right

      # Super+Alt+Shift+{H,J,K,L} to resize views
      riverctl map normal Super+Alt+Shift H resize horizontal -100
      riverctl map normal Super+Alt+Shift J resize vertical 100
      riverctl map normal Super+Alt+Shift K resize vertical -100
      riverctl map normal Super+Alt+Shift L resize horizontal 100

      # Super + Left Mouse Button to move views
      riverctl map-pointer normal Super BTN_LEFT move-view

      # Super + Right Mouse Button to resize views
      riverctl map-pointer normal Super BTN_RIGHT resize-view

      # Super + Middle Mouse Button to toggle float
      riverctl map-pointer normal Super BTN_MIDDLE toggle-float

      for i in $(seq 1 6)
      do
        tags=$((1 << ($i - 1)))

        # Super+[1-6] to focus tag [0-5]
        riverctl map normal Super $i set-focused-tags $tags

        # Super+Shift+[1-6] to tag focused view with tag [0-5]
        riverctl map normal Super+Shift $i set-view-tags $tags

        # Super+Control+[1-6] to toggle focus of tag [0-5]
        riverctl map normal Super+Control $i toggle-focused-tags $tags

        # Super+Shift+Control+[1-6] to toggle tag [0-5] of focused view
        riverctl map normal Super+Shift+Control $i toggle-view-tags $tags
      done

      # Super+0 to focus all tags
      # Super+Shift+0 to tag focused view with all tags
      all_tags=$(((1 << 32) - 1))
      riverctl map normal Super 0 set-focused-tags $all_tags
      riverctl map normal Super+Shift 0 set-view-tags $all_tags

      # Super+Space to toggle float
      riverctl map normal Super Space toggle-float

      # Super+F to toggle fullscreen
      riverctl map normal Super F toggle-fullscreen

      # Super+{Up,Right,Down,Left} to change layout orientation
      riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
      riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
      riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
      riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

      # Declare a passthrough mode. This mode has only a single mapping to return to
      # normal mode. This makes it useful for testing a nested wayland compositor
      riverctl declare-mode passthrough

      # Super+F11 to enter passthrough mode
      riverctl map normal Super F11 enter-mode passthrough

      # Super+F11 to return to normal mode
      riverctl map passthrough Super F11 enter-mode normal

      # Various media key mapping examples for both normal and locked mode which do
      # not have a modifier
      for mode in normal locked
      do
        # Eject the optical drive (well if you still have one that is)
        riverctl map $mode None XF86Eject spawn 'eject -T'

        # Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
        riverctl map $mode None XF86AudioRaiseVolume  spawn 'pamixer -i 5'
        riverctl map $mode None XF86AudioLowerVolume  spawn 'pamixer -d 5'
        riverctl map $mode None XF86AudioMute         spawn 'pamixer --toggle-mute'

        # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
        riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
        riverctl map $mode None XF86AudioPlay  spawn 'playerctl play-pause'
        riverctl map $mode None XF86AudioPrev  spawn 'playerctl previous'
        riverctl map $mode None XF86AudioNext  spawn 'playerctl next'

        # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
        riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set +5%'
        riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'
      done

      # Set background and border color (https://github.com/morhetz/gruvbox)
      riverctl background-color 0x282828
      riverctl border-color-focused 0xd65d0e
      riverctl border-color-unfocused 0x3c3836

      # Set keyboard repeat rate
      riverctl set-repeat 50 300

      # Make all views with an app-id that starts with "float" and title "foo" start floating.
      riverctl rule-add -app-id 'float*' -title 'foo' float

      # Make all views with app-id "bar" and any title use client-side decorations
      riverctl rule-add -app-id "bar" csd

      # Set the default layout generator to be rivertile and start it.
      # River will send the process group of the init executable SIGTERM on exit.
      riverctl default-layout rivertile

      # Keyboard layout
      riverctl keyboard-layout no

      # Focus follows cursor
      riverctl focus-follows-cursor normal

      # Hide cursor when typing
      riverctl hide-cursor when-typing enabled

      # Screenshot
      riverctl map normal None Print spawn "grim -g \"\$(slurp)\" - | wl-copy"

      # Colorpicker
      riverctl map normal Super C spawn "hyprpicker -n -r | wl-copy"

      # Swaylock
      riverctl map normal Super X spawn "swaylock --color 3c3836 -F -f"

      rivertile -view-padding 6 -outer-padding 6 &
      
      # Browser
      # riverctl map normal Super W spawn "firefox && riverctl set-focused-tags $((2#1))"

      # Set tags and spawn apps
      # riverctl rule-add -app-id "foot-dev" tags $((2#10))
      # riverctl spawn "foot -a foot-dev"      

      # riverctl rule-add -app-id "firefox" tags $((2#1))
      # riverctl spawn "firefox"

      # riverctl rule-add -title "Slack" tags $((2#100))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=deabakhnaapgoejhnggflphfcocnkeej"

      # riverctl rule-add -title "Cinny" tags $((2#100))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=bcngdmpegpihnheapppgoniglphkpfhm"

      # riverctl rule-add -title "Outlook (PWA)" tags $((2#1000))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=pkooggnaalmfkidjmlhoelhdllpphaga"

      # riverctl rule-add -title "Gmail" tags $((2#1000))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=fmgjjmmmlfnkbppncabfkddbjimcfncm"

      # riverctl rule-add -title "Microsoft Teams" tags $((2#100))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=cifhbcnohmdccbgoicgdjpfamggdegmo"

      # riverctl rule-add -title "Messenger" tags $((2#100))
      # riverctl spawn "chromium --profile-directory=Default1 --app-id=bbdeiblfgdokhlblpgeaokenkfknecgl"

      # Applets
      riverctl spawn "pasystray"
      riverctl spawn "blueman-applet"

      # Float metamask
      riverctl rule-add -title _crx_nkbihfbeogaeaoehlefnkodbefgpgknn float

      # Float bitwarden
      riverctl rule-add -title _crx_nngceckbapebfimnlniiiahkandclblb float     

      # Scratchpad
      scratch_tag=$((1 << 20))

      # Toggle the scratchpad with Super+P
      riverctl map normal Super P toggle-focused-tags $scratch_tag

      # Send windows to the scratchpad with Super+Shift+P
      riverctl map normal Super+Shift P set-view-tags $scratch_tag

      # Set spawn tagmask to ensure new windows don't have the scratchpad tag unless
      # explicitly set.
      all_but_scratch_tag=$(( ((1 << 32) - 1) ^ $scratch_tag ))
      riverctl spawn-tagmask $all_but_scratch_tag
     '';
    };
  }
