{
  # Openbox is the kiosk WM: decorated, movable windows for browser/media plus a
  # right-click menu, but the Zwift game window is undecorated (rule in rc.xml)
  # so the session's explicit per-monitor geometry lands pixel-exact.
  xdg.configFile."openbox/rc.xml".source = ./openbox-rc.xml;
  xdg.configFile."openbox/menu.xml".source = ./openbox-menu.xml;

  # Styled notifications (used for the warm greeting when Elin starts a ride).
  xdg.configFile."dunst/dunstrc".source = ./dunstrc;

  # Weak GPU (GTX 560 Ti, 1G VRAM): minimal zwift graphics profile for every
  # rider; applied because programs.zwift.zwiftOverrideGraphics is enabled.
  # Values follow the "basic" profile from the netbrain/zwift graphics docs,
  # with FXAA off and reduced foliage to survive two concurrent instances.
  xdg.configFile."zwift/graphics.txt".text = ''
    res 1024x576(0x)
    sres 512x512
    set gSSAO=0
    set gFXAA=0
    set gSunRays=0
    set gHeadLight=0
    set gFoliagePercent=0.3
    set gSimpleReflections=1
    set gLODBias=1
    set gShowFPS=0
  '';
}
